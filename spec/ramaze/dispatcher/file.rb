require 'spec/helper'

describe 'Dispatcher::File' do
  before :all do
    ramaze
  end

  it 'should serve from proto/public' do
  end

  it 'should serve from Global.public_root' do
    dir = Ramaze::Global.public_root = 'spec/ramaze/public'
    css = File.read(dir/'test_download.css')
    re_css = get('/test_download.css')
    re_css.body.should == css
    re_css.status.should == 200
  end

  it 'should serve from Global.public_proto' do
    file = (Ramaze::Global.public_proto/'error.zmr')
    original = File.read(file)
    get('/error.zmr').body.should == original
  end
end
