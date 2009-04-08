require 'spec/helper'

class SpecAction < Ramaze::Controller
  map '/'
  provide :html, :None

  def index
    'Hello, World!'
  end

  def bar
    "yo from bar"
  end
end

describe 'Action#render' do
  it 'works when Action is manually created' do
    action = SpecAction.resolve('/')
    action.render.should == 'Hello, World!'
  end
end
