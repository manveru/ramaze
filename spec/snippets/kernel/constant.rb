require 'spec/helper'

describe 'constant' do
  

  it 'should load from string' do
    constant('Fixnum').should == Fixnum
  end

  it 'should load from symbol' do
    constant(:Fixnum).should == Fixnum
  end
  
  it 'should handle hierarchy' do
    constant('Ramaze::Inform').should == Ramaze::Inform
  end

  it 'should be callable with explicit self' do
    Ramaze.constant('Inform').should == Ramaze::Inform
  end

  it 'should be callable with explicit self' do
    Ramaze.constant('::Ramaze').should == Ramaze
  end

end

