#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'ramaze/template'

module Ramaze::Template
  class TestTemplate < Template
    Ramaze::Controller.register_engine self, %w[ test ]

    class << self
      def transform action
        action.values_at(:method, :params, :template).to_yaml
      end
    end
  end
end

class TCTemplateController < Ramaze::Controller
  map '/'
  trait :engine => Ramaze::Template::TestTemplate
  template_root(File.dirname(__FILE__)/:template/:ramaze)

  def index *args
  end

  def some_other_method *args
  end
end

describe "testing ramaze template" do
  before :all do
    ramaze
  end

  def getpage page
    content = Ramaze::Controller.handle(page)
    @action, @params, @file = YAML.load(content)
  end

  it "Gets a blank page" do
    getpage("/index")

    @action.should == "index"
    @params.should == []
    @file.should be_nil
  end

  it "Maps the index" do
    getpage("/")

    @action.should == "index"
    @params.should == []
    @file.should be_nil
  end

  it "Parses parameters" do
    getpage("/one/two/three")

    @action.should == "index"
    @params.should == %w{one two three}
    @file.should be_nil
  end

  it "Knows about other methods" do
    getpage("/some_other_method")

    @action.should == "some_other_method"
    @params.should == []
    @file.should be_nil
  end

  it "Uses external template files" do
    getpage("/external")

    @file.should =~ /external\.test$/
    @params.should == []
    file = TCTemplateController.template_root/'external.test'
    @file.should == file
  end
end
