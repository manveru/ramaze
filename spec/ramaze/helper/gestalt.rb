require 'spec/helper'
require 'ramaze/helper/gestalt'

describe Ramaze::Helper::Gestalt do
  extend Ramaze::Helper::Gestalt

  it 'has a shortcut for Ramaze::Gestalt::new' do
    gestalt{ h1('title') }.to_s.should ==
      Ramaze::Gestalt.new{ h1('title') }.to_s
  end

  it 'has a shortcut for Ramaze::Gestalt::build' do
    build{ h1('title') }.should == '<h1>title</h1>'
  end
end
