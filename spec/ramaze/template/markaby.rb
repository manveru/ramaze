#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'markaby'

class TCTemplateMarkabyController < Ramaze::Controller
  trait :template_root => 'spec/ramaze/template/markaby/'
  trait :engine => Ramaze::Template::Markaby

  helper :markaby

  def index
    mab { h1 "Markaby Index" }
  end

  def external
  end

  def sum num1, num2
    @num1, @num2 = num1.to_i, num2.to_i
  end
end

describe "Markaby" do
  ramaze(:mapping => {'/' => TCTemplateMarkabyController})

  it "index" do
    get('/').should == '<h1>Markaby Index</h1>'
  end

  it "sum" do
    get('/sum/1/2').should == '<div>3</div>'
  end

  it "external" do
    get('/external').should == "<html><head><meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"/><title>Markaby Test</title></head><body><h1>Markaby Template</h1></body></html>"
  end

  it "should not respond to mab" do
    lambda{ get('/mab') }.should raise_error
  end
end
