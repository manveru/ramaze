require 'spec/helper'

class TCActionOne < Ramaze::Controller
  def index
    'Hello, World!'
  end
end

describe 'Action rendering' do
  before :all do
    ramaze
  end

  it 'should render' do
    action = Ramaze::Action(:method => :index, :controller => TCActionOne)
    action.render.should == 'Hello, World!'
  end
end
