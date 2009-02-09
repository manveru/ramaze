require 'spec/helper'

class TCActionOne < Ramaze::Controller
  map '/'
  provide :html => :none

  def index
    'Hello, World!'
  end

  def bar
    "yo from bar"
  end
end

describe 'Action#render' do
  it 'works when Action is manually created' do
    action = Ramaze::Action.create(:method => :index, :node => TCActionOne)
    action.render.should == 'Hello, World!'
  end
end
