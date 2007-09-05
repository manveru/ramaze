require 'spec/helper'

describe 'Dispatcher::File' do
  before :all do
    ramaze
    @public_root = Ramaze::Global.public_root = 'spec/ramaze/dispatcher/public'
  end

  it 'should serve from Global.public_root' do
    css = File.read(@public_root/'test_download.css')
    re_css = get('/test_download.css')
    re_css.body.should == css
    re_css.status.should == 200
  end

  it 'should give priority to Global.public_root' do
    file = (@public_root/'favicon.ico')
    original = File.read(file)
    get('/favicon.ico').body.should == original
  end
end
