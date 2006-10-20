require 'ramaze'
require 'test/test_helper'

include Ramaze

context "simple stuff with global" do
  specify "Global.create" do
    Global.create :foo => :bar, :x => :y
    Global.foo.should.equal :bar
    Global.x.should.equal :y
  end

  specify "just simple assignment and retrive" do
    Global.some = :xxx
    Global.some.should.equal :xxx
  end

  specify "let's force some errors" do
    lambda{ Global.duh(:bar) }.should.raise NoMethodError
  end
end
