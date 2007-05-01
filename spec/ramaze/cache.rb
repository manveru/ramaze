#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

describe "MemoryCache" do
  cache = Ramaze::MemoryCache.new

  it "delete" do
    cache.delete(:one)
    cache.delete(:two)
  end

  it "set keys" do
    (cache[:one] = 'eins').should == "eins"
    (cache[:two] = 'zwei').should == "zwei"
  end

  it "read keys" do
    cache[:one].should == 'eins'
    cache[:two].should == 'zwei'
  end

  it "values_at" do
    cache.values_at(:one, :two).should == %w[eins zwei]
  end
end

describe "YAMLStoreCache" do
  cache = Ramaze::YAMLStoreCache.new

  it "delete" do
    cache.delete(:one)
    cache.delete(:two)
  end

  it "set keys" do
    (cache[:one] = 'eins').should == "eins"
    (cache[:two] = 'zwei').should == "zwei"
  end

  it "read keys" do
    cache[:one].should == 'eins'
    cache[:two].should == 'zwei'
  end

  it "values_at" do
    cache.values_at(:one, :two).should == %w[eins zwei]
  end
end

begin
  describe "MemcachedCache" do
    cache = Ramaze::MemcachedCache.new

    it "delete" do
      cache.delete(:one)
      cache.delete(:two)
    end

    it "set keys" do
      (cache[:one] = 'eins').should == "eins"
      (cache[:two] = 'zwei').should == "zwei"
    end

    it "read keys" do
      cache[:one].should == 'eins'
      cache[:two].should == 'zwei'
    end

    it "values_at" do
      cache.values_at(:one, :two).should == %w[eins zwei]
    end
  end
rescue LoadError
  puts "cannot run test for memcached"
end
