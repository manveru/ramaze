#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

context "MemoryCache" do
  cache = MemoryCache.new

  specify "delete" do
    cache.delete(:one)
    cache.delete(:two)
  end

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

context "YAMLStoreCache" do
  cache = YAMLStoreCache.new

  specify "delete" do
    cache.delete(:one)
    cache.delete(:two)
  end

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

begin
  context "MemcachedCache" do
    cache = MemcachedCache.new

    specify "delete" do
      cache.delete(:one)
      cache.delete(:two)
    end

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
rescue LoadError
  puts "cannot run test for memcached"
end
