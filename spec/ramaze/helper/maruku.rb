require 'spec/helper'
spec_require 'maruku'

class SpecHelperMaruku < Ramaze::Controller
  map '/'
  helper :maruku

  def index
    maruku('# Hello')
  end
end

describe Ramaze::Helper::Maruku do
  behaves_like :rack_test

  it 'converts a markdown string to html' do
    get('/').body.should =~ /<h1 id=["']hello["']>Hello<\/h1>/
  end
end
