#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)

describe 'Controller::generate_mapping' do
  def gen(klass)
    Ramaze::Controller::generate_mapping(klass)
  end

  it 'maps ::ClassController to /class' do
    gen('ClassController').should == '/class'
  end

  it 'maps ::CamelCaseController to /camel_case' do
    gen('CamelCaseController').should == '/camel_case'
  end

  it 'maps Module::ClassController to /module/class' do
    gen('Module::ClassController').should == '/module/class'
  end

  it 'maps Class to /class' do
    gen('Class').should == '/class'
  end

  it 'maps Module::Class to /module/class' do
    gen('Module::Class').should == '/module/class'
  end

  it 'maps Module::Module::Class to module/module/class' do
    gen('Module::Module::Class').should == '/module/module/class'
  end

  it "maps MainController to '/'" do
    gen('MainController').should == '/'
  end

  it "doesn't map ::Controller" do
    gen('Controller').should == nil
  end

  it "doesn't map anonymous classes" do
    gen(Class.new.name).should == nil
  end
end
