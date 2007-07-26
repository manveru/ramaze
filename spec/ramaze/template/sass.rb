#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'ramaze/template/sass'

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
    get('/test').body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end
  
  it "should render a Sass template from file" do
    get('/from_file').body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end
end