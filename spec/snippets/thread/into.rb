require 'spec/helper'

describe 'Thread.into' do
  it 'should provide access to thread vars' do
    Thread.current[:foo] = :bar
    Thread.new{ Thread.current[:foo].should == nil }.join
    Thread.into{ Thread.current[:foo].should == :bar }.join
  end
end
