require File.expand_path('../../../../spec/helper', __FILE__)
require File.expand_path('../../../../examples/misc/sequel_scaffolding', __FILE__)

describe 'Sequel Scaffolding Extensions' do
  behaves_like :rack_test
  
  it 'should provide a link to manage users' do
    r = get('/user').body
    r.should.include('<a href="/user/manage_user">User</a>')
  end
  
  it 'should display users in our database' do
    r = get('/user/browse_user').body
    r.should.include('manveru')
    r.should.include('injekt')
  end
  
end