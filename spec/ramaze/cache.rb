#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

caches = {:memory => 'Hash', :yaml => 'Ramaze::YAMLStoreCache'}

begin
  require 'memcache'
  caches[:memcached] = 'Ramaze::MemcachedCache'
rescue LoadError
  puts "skipping memcached"
end

caches.each do |cache, name|
  describe "#{name} setup" do
    it "should be assignable to Global" do
      Ramaze::Global.cache = cache
      Ramaze::Global.cache.to_s.should == name
    end

    it "should do .new" do
      @cache = Ramaze::Global.cache.new
      @cache.class.name.should == name
    end
  end

  describe "#{name} modification" do
    setup do
      Ramaze::Global.cache = cache
      @cache = Ramaze::Global.cache.new
    end

    after :each do
      @cache.clear
    end

    after :all do
      FileUtils.rm(@cache.file) if cache == :yaml
    end

    it "should be assignable with #[]=" do
      @cache[:foo] = :bar
      @cache[:foo].should == :bar
    end

    it "should be retrievable with #[]" do
      @cache[:yoh] = :bar
      @cache[:yoh].should == :bar
    end

    it "should delete keys" do
      @cache[:bar] = :duh
      @cache.delete(:bar)
      @cache[:bar].should be_nil
    end

    it "should show values for multiple keys" do
      @cache[:baz] = :foo
      @cache[:beh] = :feh
      @cache.values_at(:baz, :beh).should == [:foo, :feh]
    end
  end
end
