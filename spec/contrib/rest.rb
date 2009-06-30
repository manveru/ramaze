require File.expand_path('../../../spec/helper', __FILE__)
require 'ramaze/contrib/rest'

class Posts < Ramaze::Controller
  map '/'

  def show; 'Showing' end
  def create; 'Creating' end
  def update; 'Updating' end
  def destroy; 'Destroying' end

  def show_other; 'Showing other' end
end

describe 'Contrib REST rewrite' do
  behaves_like :rack_test

  it('rewrites GET to show'){          get('/').body.should == 'Showing' }
  it('rewrites POST to create'){      post('/').body.should == 'Creating' }
  it('rewrites PUT to update'){        put('/').body.should == 'Updating' }
  it('rewrites DELETE to destroy'){ delete('/').body.should == 'Destroying' }

  it 'is configurable' do
    Ramaze.options.rest_rewrite['GET'] = 'show_other'

    get('/').body.should == 'Showing other'
  end
end
