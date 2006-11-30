require 'ramaze'
require 'test/test_helper'

include Ramaze

context "Global" do
  specify "create" do
    Global.create :foo => :bar, :x => :y
    Global.foo.should.equal :bar
    Global.x.should.equal :y
  end

  specify "update" do
    Global.update :foo => :fuz, :baz => :foobar
    Global[:foo].should == :bar
    Global[:baz].should == :foobar
  end

  specify "just simple assignment and retrive" do
    Global.some = :xxx
    Global.some.should.equal :xxx
  end

  specify "let's force some errors" do
    lambda{ Global.duh(:bar) }.should.raise NoMethodError
  end
end
