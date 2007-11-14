require 'spec/helper'

class TCActionCache < Ramaze::Controller
  map '/'
  helper :cache

  def index
    rand
  end

  cache :index
end

describe 'Action rendering' do
  before :all do
    @public_root = __DIR__ / :public
    FileUtils.mkdir_p @public_root
    ramaze :file_cache => true
  end

  it 'should render' do
    lambda{ get('/') }.should_not change{ get('/').body }
    File.file?(@public_root/'index').should be_true
  end

  after :all do
    FileUtils.rm_rf @public_root
  end
end
