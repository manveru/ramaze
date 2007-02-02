#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'
begin
  require 'rubygems'
rescue LoadError
end

include Ramaze

class TCTemplateMarkabyController < Template::Markaby
  trait :template_root => 'spec/template/markaby/'

  def index
    mab { h1 "Markaby Index" }
  end

  def external
  end

  def sum num1, num2
    @num1, @num2 = num1.to_i, num2.to_i
  end
end

context "Markaby" do
  ramaze(:mapping => {'/' => TCTemplateMarkabyController})

  def mab(&block)
    TCTemplateMarkabyController.new.send(:mab, &block)
  end

  specify "index" do
    get('/').should == '<h1>Markaby Index</h1>'
  end

  specify "sum" do
    get('/sum/1/2').should == '<div>3</div>'
  end

  specify "external" do
    get('/external').should == "<html><head><meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"/><title>Markaby Test</title></head><body><h1>Markaby Template</h1></body></html>"
  end

  specify "should not respond to mab" do
    lambda{get('/mab')}.should_raise
  end

  specify "simple" do
    mab{ hr }.should          == "<hr/>"
    mab{ p 'foo' }.should     == "<p>foo</p>"
    mab{ p { 'foo' } }.should == "<p>foo</p>"
  end

  specify "classes and ids" do
    mab{ div.one '' }.should      == "<div class=\"one\"></div>"
    mab{ div.one.two '' }.should  == "<div class=\"one two\"></div>"
    mab{ div.three! '' }.should   == %{<div id="three"></div>}
  end

  specify "escaping" do
    mab{ h1 'Apples & Oranges' }.should                   == "<h1>Apples &amp; Oranges</h1>"
    mab{ h1 { 'Apples & Oranges' } }.should               == "<h1>Apples & Oranges</h1>"
    mab{ h1 'Apples', :class => 'fruits&floots' }.should  == "<h1 class=\"fruits&amp;floots\">Apples</h1>"
  end

  specify "capturing" do
    builder = Markaby::Builder.new
    builder.to_s.should_be.empty
    builder.capture { h1 'TEST' }.should == mab{ h1 "TEST" }
    builder.to_s.should_be.empty
    mab{ capture { h1 'hello world' }; nil }.should_be.empty
    mab{ div { capture { h1 'TEST' } } }.should ==  mab { div { h1 'TEST' } }
  end
end
