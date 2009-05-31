require 'spec/helper'

class SpecAppMain < Ramaze::Controller
  map '/', :core

  def index
    'core main'
  end
end

class SpecAppTwo < Ramaze::Controller
  map '/two', :core

  def index
    'core two'
  end
end

class SpecAppOtherMain < Ramaze::Controller
  map '/', :other

  def index
    'other main'
  end
end

class SpecAppOtherTwo < Ramaze::Controller
  map '/two', :other

  def index
    'other two'
  end
end

Ramaze::App[:core].location = '/'
Ramaze::App[:other].location = '/other'

describe Ramaze::App do
  behaves_like :rack_test

  it 'handles call with rack env' do
    get('/').body.should == 'core main'
    get('/two').body.should == 'core two'
    get('/other').body.should == 'other main'
    get('/other/two').body.should == 'other two'
  end
end
