#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'
require 'ramaze/store/default'

context "initialize an Store" do
  db = 'db.yaml'

  def add hash = {}
    Books.merge!(hash)
  end

  specify "Store::Default.new" do
    Books = Ramaze::Store::Default.new(db)
    Books.db.should.is_a?(YAML::Store)
  end

  specify "store and retrieve something" do
    add 'Pickaxe' => 'good book'
    Books['Pickaxe'].should == 'good book'
  end

  specify "empty?" do
    add 'Pickaxe' => 'good book'

    Books.empty?.should == false
    Books.clear
    Books.empty?.should == true
  end

  specify "size" do
    Books.size.should == 0

    {
      'Pickaxe' => 'good book',
      '1984' => 'scary',
      'Brave new World' => 'interesting',
    }.each_with_index do |(title, content), i|
      add title => content
      Books.size.should == i + 1
    end
  end

  specify "Enumerable" do
    add 'Pickaxe' => 'good book', '1984' => 'scary'

    Books.each do |title, content|
      [title, content].compact.empty?.should == false
      Books[title].should == content
    end
  end

  specify "merge and merge!" do
    books = {'Pickaxe' => 'good book', '1984' => 'scary'}
    add books

    bnw = {'Brave new World' => 'interesting'}

    Books.merge(bnw).should == books.merge(bnw)

    Books[bnw.keys.first].should == nil

    Books.merge!(bnw).should == books.merge(bnw)

    Books[bnw.keys.first].should == bnw.values.first
    
    Books.size.should == 3
  end

  teardown do
    FileUtils.rm db
  end
end
