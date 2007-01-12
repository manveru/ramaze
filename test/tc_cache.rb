#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

context "MemoryCache" do
  cache = MemoryCache.new

  specify "set keys" do
    (cache[:one] = 'eins').should == "eins"
    (cache[:two] = 'zwei').should == "zwei"
  end

  specify "read keys" do
    cache[:one].should == 'eins'
    cache[:two].should == 'zwei'
  end

  specify "values_at" do
    cache.values_at(:one, :two).should == %w[eins zwei]
  end
end

context "MemcachedCache" do
  cache = MemcachedCache.new

  specify "set keys" do
    (cache[:one] = 'eins').should == "eins"
    (cache[:two] = 'zwei').should == "zwei"
  end

  specify "read keys" do
    cache[:one].should == 'eins'
    cache[:two].should == 'zwei'
  end

  specify "values_at" do
    cache.values_at(:one, :two).should == %w[eins zwei]
  end
end
