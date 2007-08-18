require 'spec/helper'

class TCActionCache < Ramaze::Controller
  map '/'
  helper :cache

  def index
    rand
  end

  trait :actions_cached => [:index]
end

describe 'Action rendering' do
  before :all do
    @public_root = "#{File.expand_path(File.dirname(__FILE__))}/public"
    FileUtils.mkdir_p @public_root
    ramaze :action_file_cached => true, :public_root => @public_root
  end

  after :all do
    FileUtils.rm_rf @public_root
  end

  it 'should render' do
    lambda{ get('/') }.should_not change{ get('/').body }
  end
end
