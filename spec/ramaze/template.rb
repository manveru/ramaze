#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'ramaze/template'

module Ramaze::Template
  class TestTemplate < Template
    Ramaze::Controller.register_engine self, %w[ test ]
    class << self
      def transform controller, options = {}
        action, parameter, file, bound = *super
        [ controller.class, action, parameter.join('|'), file ].join ','
      end
    end
  end
end

class TCTemplateController < Ramaze::Controller
  trait :engine => Ramaze::Template::TestTemplate
  trait :template_root => 'spec/ramaze/template/ramaze/'

  def index *args
  end

  def some_other_method *args
  end
end

describe "testing ramaze template" do
  ramaze(:mapping => {'/' => TCTemplateController})

  def getpage page
    controller,action,parameter,file=get( page ).body.split(',')
    parameters = parameter ? parameter.split('|') : nil
    parameters = nil if parameters and parameters.size == 0
    [controller,action,parameters,file]
  end

  it "Gets a blank page" do
    controller,action,parameters,file=getpage("/index")
    controller.should == "TCTemplateController"
    action.should == "index"
    parameters.should == nil
    file.should == nil
  end

  it "Maps the index" do
    controller,action,parameters,file=getpage("/")
    controller.should == "TCTemplateController"
    action.should == "index"
    parameters.should == nil
    file.should == nil
  end

  it "Parses parameters" do
    controller,action,parameters,file=getpage("/one/two/three")
    controller.should == "TCTemplateController"
    action.should == "index"
    parameters.should == %w{one two three}
    file.should == nil
  end

  it "Knows about other methods" do
    controller,action,parameters,file=getpage("/some_other_method")
    controller.should == "TCTemplateController"
    action.should == "some_other_method"
    parameters.should == nil
    file.should == nil
  end

  it "Uses external template files" do
    controller,action,parameters,file=getpage("/external")
    controller.should == "TCTemplateController"
    action.should == "external"
    parameters.should == nil
    file.should == File::expand_path('spec/ramaze/template/ramaze/external.test')
  end

end
