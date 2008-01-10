#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCPartialHelperController < Ramaze::Controller
  map '/'
  helper :partial

  def index
    '<html><head><title>#{render_partial("/title")}</title></head></html>'
  end

  def title
    "Title"
  end

  def composed
    @here = 'there'
    'From Action | ' +
    render_template("partial.xhtml")
  end

  def recursive
    @n = 1
  end

  def test_locals
    render_template 'locals.xhtml', :say => 'Hello', :to => 'World'
  end
end

describe "PartialHelper" do
  behaves_like 'http'
  ramaze

  it "should render partials" do
    get('/').body.should == '<html><head><title>Title</title></head></html>'
  end

  it 'should be able to render a template in the current scope' do
    get('/composed').body.should == 'From Action | From Partial there'
  end

  it 'should render_template in a loop' do
    get('/loop').body.gsub(/\s/,'').should == '12345'
  end

  it 'should work recursively' do
    get('/recursive').body.gsub(/\s/,'').should == '{1{2{3{44}4}3}2}'
  end

  it 'should support locals' do
    get('/test_locals').body.should == 'Hello, World!'
  end
end
