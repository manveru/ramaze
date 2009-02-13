#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

module Ramaze
  module View
    module MyEngine
      def self.render(action, string)
        string
      end
    end

    register View::MyEngine.name, :my
  end
end

class SpecView < Ramaze::Controller
  map '/'
  engine :MyEngine

  def index
    'Hello, World!'
  end
end

describe Ramaze::View do
  behaves_like :mock

  it 'uses MyEngine' do
    get('/').body.should == 'Hello, World!'
  end
end
