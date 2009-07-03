require File.expand_path('../../../../spec/helper', __FILE__)
require File.expand_path('../../../../examples/helpers/httpdigest', __FILE__)

# Not sure if we should change the behaviour of digest_authorize, it keeps
# challenging the authorization even after a logout, which will log us in right
# away again.
#
# IMHO, digest_authorize should only be valid for the following request.
#
# So for now, we have to reset the values of @digest_username and
# @digest_password before we make a request.

describe Ramaze::Helper do
  behaves_like :rack_test

  it 'authorizes request for /eyes_only' do
    digest_authorize nil, nil
    get '/eyes_only'
    last_response.status.should == 401
    last_response.body.should == "Unauthorized"

    digest_authorize 'foo', 'oof'
    get '/eyes_only'
    last_response.status.should == 200
    last_response.body.should == "Shhhh don't tell anyone"
  end

  it 'authorizes request for /secret as admin' do
    digest_authorize nil, nil
    get '/secret'
    last_response.status.should == 401
    last_response.body.should == 'Unauthorized'

    digest_authorize 'admin', 'secret'
    get '/secret'

    last_response.status.should == 200
    last_response.body.should == "Hello <em>admin</em>, welcome to SECRET world."
  end

  it 'authorizes request for /secret as root' do
    digest_authorize nil, nil
    get '/secret'
    last_response.status.should == 401
    last_response.body.should == 'Unauthorized'

    digest_authorize 'root', 'password'
    get '/secret'
    last_response.status.should == 200
    last_response.body.should == "Hello <em>root</em>, welcome to SECRET world."
  end

  it 'authorizes request for /guest' do
    digest_authorize nil, nil
    get '/guest'
    last_response.status.should == 401
    last_response.body.should == 'Unauthorized'

    digest_authorize 'guest', 'access'
    get '/guest'
    last_response.status.should == 200
    last_response.body.should == "Hello <em>guest</em>, welcome to GUEST world."
  end
end
