#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCPartialHelperController < Ramaze::Controller
  map '/'
  provide :html => :nagoro, :xhtml => :nagoro

  def index
    '<html><head><title><render src="/title" /></title></head></html>'
  end

  def title
    "Title"
  end

  def with_params
    '<html><head><title>#{render_partial("/message", {:msg=>"hello"})}</title></head></html>'
  end

  def message
    "Message: #{request[:msg]}"
  end

  def composed
    @here = 'there'
    'From Action | ' << render_template("partial.xhtml")
  end

  def recursive locals = false
    respond render_template('recursive_locals.xhtml', :n => 1) if locals
    @n = 1
  end

  def test_locals
    render_template('locals.xhtml', :say => 'Hello', :to => 'World')
  end

  def test_local_ivars
    render_template 'recursive_local_ivars.xhtml', :n => 1
  end

  def test_without_ext
    render_template :locals, :say => 'Hi', :to => 'World'
  end
end

Innate.options.app.root = '/'
Innate.options.app.view = __DIR__(:view)

describe Ramaze::Helper::Partial do
  def get(*args)
    Innate::Mock.get(*args)
  end

  should 'render partials' do
    get('/').body.should == '<html><head><title>Title</title></head></html>'
  end

  should 'render partials with params' do
    get('/with_params').body.should == '<html><head><title>Message: hello</title></head></html>'
  end

  should 'be able to render a template in the current scope' do
    get('/composed').body.should == 'From Action | From Partial there'
  end

  should 'render_template in a loop' do
    get('/loop').body.gsub(/\s/,'').should == '12345'
  end

  should 'work recursively' do
    get('/recursive').body.gsub(/\s/,'').should == '{1{2{3{44}4}3}2}'
  end
end

__END__

  should 'support locals' do
    get('/test_locals').body.should == 'Hello, World!'
  end

  should 'work recursively with locals' do
    get('/recursive/true').body.gsub(/\s/,'').should == '{1{2{3{44}3}2}1}'
  end

  should 'set ivars in addition to locals' do
    get('/test_local_ivars').body.gsub(/\s/,'').should == '{1{2{3{44}3}2}1}'
  end

  should 'not require file extension' do
    get('/test_without_ext').body.should == 'Hi, World!'
  end
end
