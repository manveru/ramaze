#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'erector'

Ramaze::App.options.views = 'erector'
Ramaze::App.options.layouts = 'erector'

class SpecErector < Ramaze::Controller
  map '/'
  engine :Erector
  helper :erector
  layout :layout

  def invoke_helper_method 
  end

  def index
    erector { h1 "Erector Index" }
  end

  def links
    erector {
      ul {
        li { a(:href => r(:index)) { text "Index page" } }
        li { a(:href => r(:internal)){ text "Internal template" } }
        li { a(:href => r(:external)){ text "External template" } }
      }
    }
  end

  def strict_xhtml
  end

  def ie_if
    erector {
      ie_if("lt IE 8") {
        css "ie.css"
        css "test2.css", :media => 'screen'
      }
    }
  end

  def css
    erector {
      css "test.css", :media => 'screen'
    }
  end

  def sum(num1, num2)
    @num1, @num2 = num1.to_i, num2.to_i
  end
end

describe Ramaze::View::Erector do
  behaves_like :rack_test

  should 'use erector methods' do
    get('/').body.should == '<div><h1>Erector Index</h1></div>'
  end

  should 'use other helper methods' do
    get('/links').body.should == '<div><ul><li><a href="/index">Index page</a></li><li><a href="/internal">Internal template</a></li><li><a href="/external">External template</a></li></ul></div>'
  end

  should 'render external template' do
    get('/external').body.should == "<div><h1>External Erector View Template</h1></div>"
  end

  should 'render external template with instance variables' do
    get('/sum/1/2').body.should == '<div><p>3</p></div>'
  end

  should 'render external strict xhtml template' do
    get('/strict_xhtml').body.should == "<div><?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"DTD/xhtml1-strict.dtd\"><html lang=\"en\" xml:lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\"><p>STRICT!</p></html></div>"
  end

  should 'render css link with merged options' do
    get('/css').body.should == "<div><link href=\"test.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" /></div>"
  end

  should 'render ie conditional' do
    get('/ie_if').body.should == "<div><!--[if lt IE 8]><link href=\"ie.css\" rel=\"stylesheet\" type=\"text/css\" /><link href=\"test2.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" /><![endif]--></div>"
  end

  should 'invoke helper methods from external template'  do
    get('/invoke_helper_method').body.should == "<div><a href=\"/index\">Index page</a></div>"
  end
end
