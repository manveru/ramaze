#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

Ramaze.options.app.root = '/'
Ramaze.options.app.view = __DIR__(:view)

class BaseController < Ramaze::Controller
  view_root '/base'
  engine :Nagoro

  alias_view :foo, :bar
  alias_view :one, :another, self

  def test() 'test' end
end

class MainController < BaseController
  map '/'
end

describe 'Controller' do
  behaves_like :mock

  it 'allows sub-classing MainController' do
    get('/test').body.should == 'test'
  end

  it 'respects view aliase from superclass, with no explicit controller' do
    # The template file it should use is view/bar.xhtml, as the template mapping doesn't
    # specify a controller, so it will be implicitly relative to MainController.
    get('/foo').body.should == 'bar'
  end

  it 'respects view aliase from superclass, with an explicit controller' do
    # Note that the template file it should use is view/base/another.xhtml, because
    # BaseController explicitly specifies the template mapping in relation to self.
    get('/one').body.should == 'another'
  end
end
