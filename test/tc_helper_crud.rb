#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class User
  attr_accessor :name, :oid

  class << self
    STORE = []

    def create
      instance = self.new
      instance.oid = STORE.size
      Thread.current[:request].post_query.each do |key, value|
        instance.send("#{key}=", value)
      end
      STORE << instance
      instance.oid
    end

    def update(oid)
      instance = STORE[oid.to_i]
      Thread.current[:request].post_query.each do |key, value|
        instance.send("#{key}=", value)
      end
      STORE[oid.to_i].inspect
    end

    def read(oid)
      STORE[oid.to_i].inspect
    end

    def delete(oid)
      STORE.delete_at(oid.to_i).inspect
    end
  end

  def inspect
    "<User @oid=#{oid} @name=#{name.inspect}>"
  end
end

class TCCrudHelperController < Template::Ramaze
  helper :crud

  crud User

  def index
    self.class.name
  end
end

context "CrudHelper" do
  ramaze :mapping => {'/' => TCCrudHelperController}

  oid = post('/User/create', :name => 'manveru')

  specify "read" do
    get("/User/read/#{oid}").should == '<User @oid=0 @name="manveru">'
  end

  specify "update" do
    post("/User/update/#{oid}", :name => 'madveru')
    get("/User/read/#{oid}").should == '<User @oid=0 @name="madveru">'
  end

  specify "delete" do
    get("/User/delete/#{oid}").should == '<User @oid=0 @name="madveru">'
    get("/User/read/#{oid}").should == 'nil'
  end
end
