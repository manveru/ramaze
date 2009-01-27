require 'spec/helper'

class SpecHaml < Ramaze::Controller
  map '/'
  provide :html => :haml

  def index
    '.hello'
  end

  def with_helper
    '%a{:href => r(:with_helper)} me'
  end

  def with_instance_variable
    @name = 'manveru'
    '.hello= @name'
  end
end

describe 'Innate::View::Haml' do
  behaves_like :mock

  should 'render' do
    get('/').body.
      should == "<div class='hello'></div>\n"
  end

  should 'render with helper methods' do
    get('/with_helper').body.
      should == "<a href='/with_helper'>me</a>\n"
  end

  should 'render with instance variable' do
    get('/with_instance_variable').body.
      should == "<div class='hello'>manveru</div>\n"
  end
end
