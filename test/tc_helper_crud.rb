#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class UserStub
end

class TCCrudHelperController < Template::Ramaze
  helper :crud

  crud UserStub, 'custom' => :customized

  def index
    self.class.name
  end

  def check_trinity
    request.request_method
  end
end

context "CrudHelper" do
  ramaze :mapping => {'/' => TCCrudHelperController}

  specify "create" do
    UserStub.stub!(:create).and_return(:created)

    UserStub.should_receive(:create).and_return('created')
    post('/UserStub/create', :name => 'manveru').should == 'created'
  end

  specify "read" do
    UserStub.stub!(:read).and_return(:read)

    UserStub.should_receive(:read, 1).and_return('read 1')
    get('/UserStub/read/1').should == 'read 1'
  end

  specify "update" do
    UserStub.stub!(:update).and_return(:updated)

    UserStub.should_receive(:update, 1).and_return('updated 1')
    post('/UserStub/update', :oid => 1).should == 'updated 1'
  end

  specify "delete" do
    UserStub.stub!(:delete).and_return(:deleted)

    UserStub.should_receive(:delete, 1).and_return('deleted 1')
    get('/UserStub/delete/1').should == 'deleted 1'
  end

  specify "custom" do
    UserStub.stub!(:customized).and_return('customized meth')

    UserStub.should_receive(:customized).and_return('customized meth called')
    get('/UserStub/custom').should == 'customized meth called'
  end

  specify "Trinity included?" do
    get('/check_trinity').should == 'GET'
  end
end
