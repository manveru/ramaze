require 'ramaze'
require 'ramaze/spec'

require __DIR__('../start')

describe MainController do
  behaves_like :mock

  should 'show start page' do
    got = get('/')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should =~ /<h1>Welcome to Ramaze!<\/h1>/
  end

  should 'show /notemplate' do
    got = get('/notemplate')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should =~ /there is no 'notemplate.xhtml' associated with this action/
  end
end
