#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

Ramaze.options.app.root = __DIR__
Ramaze.options.app.view = 'sass'

class SpecSass < Ramaze::Controller
  map '/'
  provide :css => :sass

  def style
%{
body
  :margin 1em

  #content
    :text-align center
}
  end
end

class SpecSassOptions < Ramaze::Controller
  map '/options'
  provide :css => :sass
  trait :sass_options => { :style => :compact }

  def test
%{
body
  margin: 1em

  #content
    font:
      family: monospace
      size: 10pt
}
  end
end

describe Ramaze::View::Sass do
  behaves_like :mock

  should 'render inline' do
    got = get('/style.css')
    got.status.should == 200
    got['Content-Type'].should == 'text/css'
    got.body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end

  should 'render from file' do
    got = get('/file.css')
    got.status.should == 200
    got['Content-Type'].should == 'text/css'
    got.body.strip.should ==
"body {
  margin: 1em; }
  body #content {
    text-align: center; }"
  end

  should 'use sass options' do
    got = get('/options/test.css')
    got.status.should == 200
    got['Content-Type'].should == 'text/css'
    got.body.should.not =~ /^ +/
  end
end
