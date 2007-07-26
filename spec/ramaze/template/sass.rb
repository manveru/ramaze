#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'sass/engine'

class TCTemplateSassController < Ramaze::Controller
  map '/'
  template_root 'spec/ramaze/template/sass/'
  trait :engine => Ramaze::Template::Sass

  def test
%{
body
  :margin 1em
  
  #content
    :text-align center
}
  end
end

describe "Simply calling" do
  ramaze(:compile => true)

  it "should render an inline Sass template" do
    r = get('/test')
    r.headers['Content-Type'].should == "text/css"
    r.body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end
  
  it "should render a Sass template from file" do
    r = get('/from_file')
    r.headers['Content-Type'].should == "text/css"
    r.body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end
end
