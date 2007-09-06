require 'spec/helper'

describe "Struct#values_at" do
  Point = Struct.new(:x,:y)

  it "should access a single value" do
    Point.new(1,2).values_at(:x).should == [1]
  end

  it "should access multiple values" do
    Point.new(1,2).values_at(:x,:y).should == [1,2]
  end

  it "should access values regardless of order" do
    Point.new(1,2).values_at(:y,:x).should == [2,1]
  end

  it "should get same value twice" do
    Point.new(1,2).values_at(:x,:x).should == [1,1]
  end

  it "should raise on wrong value" do
    # shouldn't this be NoMethodError ?
    lambda{Point.new(1,2).values_at(:k)}.should raise_error(NameError)
  end

  it "should work with strings" do
    Point.new(1).values_at('x').should == [1]
  end

  it "should work with numbers (ruby compat)" do
    Point.new(1).values_at(0).should == [1]
  end

  it "should work with mixed args" do
    Point.new(1).values_at(0,:x,'x',:y).should == [1,1,1,nil]
  end

end
