require 'spec/helper'

describe Ramaze::Struct do
  should 'provide #values_at' do
    Point = Ramaze::Struct.new(:x, :y)
    point = Point.new(15, 10)

    point.values_at(1, 0).should == [10, 15]
    point.values_at(0..1).should == [15, 10]
    point.values_at(:y, :x).should == [10, 15]
  end
end
