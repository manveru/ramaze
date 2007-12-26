require 'spec'
require File.expand_path(__FILE__).gsub('/spec/', '/lib/ramaze/')

describe "Struct.fill" do

  Point = Struct.new(:x,:y)
  it "should return a well set struct" do
    p = Point.fill(:x=>1,:y=>2)
    p.should be_an_instance_of(Point)
    p[0].should == 1
    p[1].should == 2
  end

  it "should work with partial arguments" do
    p = Point.fill(:x=>1)
    p.should be_an_instance_of(Point)
    p[0].should == 1
    p[1].should == nil
  end

  it "should not fail with foreign keys" do
    p = Point.fill(:k=>1)
    p.should be_an_instance_of(Point)
    p[0].should == nil
    p[1].should == nil
  end

end
