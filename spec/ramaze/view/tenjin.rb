require 'spec/helper'

class SpecTenjin < Ramaze::Controller
  map '/'
  provide :html => :tenjin

  def index
    '<div class="hello"></div>'
  end

  def with_helper
    '<a href="#{r(:with_helper)}">me</a>'
  end

  def with_instance_variable
    @name = 'manveru'
    '<div class="hello">#{@name}</div>'
  end
end

describe 'Innate::View::Haml' do
  behaves_like :mock

  should 'render' do
    get('/').body.should == '<div class="hello"></div>'
  end

  should 'render with helper methods' do
    get('/with_helper').body.should == '<a href="/with_helper">me</a>'
  end

  should 'render with instance variable' do
    get('/with_instance_variable').body.
      should == '<div class="hello">manveru</div>'
  end
end
