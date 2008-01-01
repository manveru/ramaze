require 'lib/ramaze/spec/helper/snippets'

describe "Struct.fill" do
  Point = Struct.new(:x,:y)

  it "should return a well set struct" do
    point = Point.fill(:x=>1,:y=>2)
    point.should.instance_of? Point
    point[0].should == 1
    point[1].should == 2
  end

  it "should work with partial arguments" do
    point = Point.fill(:x=>1)
    point.should.instance_of(Point)
    point[0].should == 1
    point[1].should == nil
  end

  it "should not fail with foreign keys" do
    point = Point.fill(:k=>1)
    point.should.instance_of(Point)
    point[0].should == nil
    point[1].should == nil
  end
end
