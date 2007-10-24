require 'spec/helper'

describe 'OrderedSet' do
  os = OrderedSet.new([1,2,3,1])

  it 'should not contain duplicates' do
    os.should == [1,2,3]
  end

  it 'should remove duplicates added' do
    os << 1
    os.should == [1,2,3]
    os.push 1
    os.should == [1,2,3]
    os.unshift 1
    os.should == [1,2,3]
  end
end