#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'xml/xslt'
testcase_requires 'ramaze/gestalt'

class TCTemplateXSLTController < Ramaze::Controller
  template_root 'spec/ramaze/template/xslt/'
  trait :engine       => Ramaze::Template::XSLT
  trait :xslt_options => { :fun_xmlns => 'urn:test' }

  def index
    gestalt {
      hi 'tobi'
    }
  end

  def ruby_version
    @version = RUBY_VERSION

    gestalt {
      document
    }
  end

  def xslt_get_ruby_version
    @version
  end

  private

  def gestalt &block
    Ramaze::Gestalt.new(&block).to_s
  end

end

describe "XSLT" do
  ramaze(:mapping => {'/' => TCTemplateXSLTController})

  it "index" do
    get('/').body.should == "hi tobi"
  end

  it "ruby_version through external functions" do
    get('/ruby_version').body.should == RUBY_VERSION
  end
end

