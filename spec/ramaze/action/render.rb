require 'spec/helper'

class TCActionOne < Ramaze::Controller
  map '/'

  def index
    'Hello, World!'
  end

  def foo
    Ramaze::Action(:controller => self.class, :method => :bar).render
  end

  def bar
    "yo from bar"
  end
end

ramaze

describe 'Action rendering' do
  behaves_like "http"

  it 'should render' do
    action = Ramaze::Action(:method => :index, :controller => TCActionOne)
    action.render.should == 'Hello, World!'
  end

  it 'should render inside the controller' do
    get('/foo').body.should == 'yo from bar'
  end
end
