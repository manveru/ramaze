require 'spec/helper'

describe 'Action() basics' do
  it 'should have useful defaults' do
    action = Ramaze::Action()

    action.params.should == []
    action.method.should be_nil
    action.template.should be_nil
  end

  it 'should sanitize parameters' do
    action = Ramaze::Action :params => [[1],[2],nil,'%20'],
                            :method => :foo

    action.params.should == ['1', '2', ' ']
    action.method.should == 'foo'
  end
end
