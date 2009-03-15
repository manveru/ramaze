require 'spec/helper'

describe 'Controller::mapping' do
  def mapping(klass)
    Ramaze::Controller::generate_mapping(klass)
  end

  it 'maps ::ClassController to /class' do
    mapping('ClassController').should == '/class'
  end

  it 'maps ::CamelCaseController to /camel_case' do
    mapping('CamelCaseController').should == '/camel_case'
  end

  it 'maps Module::ClassController to /module/class' do
    mapping('Module::ClassController').should == '/module/class'
  end

  it 'maps Class to /class' do
    mapping('Class').should == '/class'
  end

  it 'maps Module::Class to /module/class' do
    mapping('Module::Class').should == '/module/class'
  end

  it 'maps Module::Module::Class to module/module/class' do
    mapping('Module::Module::Class').should == '/module/module/class'
  end

  it "maps MainController to '/'" do
    mapping('MainController').should == '/'
  end

  it "doesn't map ::Controller" do
    mapping('Controller').should == nil
  end

  it "doesn't map anonymous classes" do
    mapping(Class.new.name).should == nil
  end
end

class SpecControllerMapping < Ramaze::Controller
  def index
    'automatically mapped'
  end
end

Ramaze.setup_dependencies

describe 'Controller automap' do
  behaves_like :mock

  it 'automatically creates an app and maps the controller into it' do
    get('/spec_controller_mapping').body.should == 'automatically mapped'
  end
end
