#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'sass/engine'

class TCTemplateSassController < Ramaze::Controller
  map '/'
  template_root 'spec/ramaze/template/sass/'
  trait :engine => Ramaze::Template::Sass

  define_method('style.css') do
%{
body
  :margin 1em
  
  #content
    :text-align center
}
  end
end

describe "Sass templates" do
  ramaze(:compile => true)

  it "should render inline" do
    r = get('/style.css')
    r.headers['Content-Type'].should == "text/css"
    r.body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end
  
  it "should render from file" do
    r = get('/file.css')
    r.headers['Content-Type'].should == "text/css"
    r.body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end
end
