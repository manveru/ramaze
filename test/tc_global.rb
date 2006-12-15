#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

context "Global" do
  specify "just simple assignment and retrive" do
    Global.some = :xxx
    Global.some.should == :xxx
  end

  specify "setup" do
    Global.setup :a => :b
    Global.a.should == :b
    Global.some.should == :xxx
    Global.setup :a => :c
    Global.a.should == :c
  end

  specify "more neat stuff" do
    Global.update :a => :d, :foo => :bar
    Global.a.should == :c
    Global.foo.should == :bar
  end

  specify "values_at" do
    Global.values_at(:a, :foo).should == [:c, :bar]
  end

  specify "getting thready" do
    (1..10).each do |i|
      Thread.new do
        sleep i / 10.0
        Global[:i] = i
        Thread.main[:i] = i
      end
    end
    sleep 0.5
    Global[:i].should == Thread.main[:i]
    Global[:i].should == 5
  end
end
