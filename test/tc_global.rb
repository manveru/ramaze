#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

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

  specify "setup" do
    Global.setup :foo => :baz, :foobar => :bar
    Global.foo.should == :baz
    Global.foobar.should == :bar
    Global.update :foo => :bar
    Global.foo.should == :baz
    Global.foobar.should == :bar
  end

  specify "just simple assignment and retrive" do
    Global.some = :xxx
    Global.some.should.equal :xxx
  end
end
