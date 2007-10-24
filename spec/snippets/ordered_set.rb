require 'spec/helper'

describe 'OrderedSet' do
  os = OrderedSet.new(1,2,3,1)

  it 'should create sets' do
    OrderedSet.new.should == []
    os.should == OrderedSet.new([1,2,3,1])
  end

  it 'should not contain duplicates' do
    os.should == [1,2,3]
  end

  it 'should remove duplicates added' do
    os << 4
    os.should == [1,2,3,4]

    os << 1
    os.should == [1,2,3,4]

    os.push 1
    os.should == [1,2,3,4]

    os.unshift 1
    os.should == [1,2,3,4]

    os.unshift 3
    os.should == [3,1,2,4]

    os.unshift 5
    os.should == [5,3,1,2,4]

    os.delete 4
    os.should == [5,3,1,2]

    os[0] = 1
    os.should == [1,3,2]
  end
end