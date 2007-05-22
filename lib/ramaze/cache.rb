#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/cache/memory'

module Ramaze
  autoload :YAMLStoreCache, "ramaze/cache/yaml_store.rb"
  autoload :MemcachedCache, "ramaze/cache/memcached.rb"

  # This is the wrapper of all caches, providing mechanism
  # for switching caching from one adapter to another.

  class Cache
    include Enumerable
    CACHES = {}

    # This will define a method to access a new cache directly over
    # sinleton-methods on Cache

    def self.add *keys
      keys.each do |key|
        CACHES[key] = new
        self.class.class_eval do
          define_method(key){ CACHES[key] }
        end
      end
    end

    def initialize(cache = Global.cache)
      @cache = cache.new
    end

    def [](key)
      @cache[key.to_s]
    end

    def []=(key, value)
      @cache[key.to_s] = value
    end

    def delete(*args)
      args.each do |arg|
        @cache.delete(arg.to_s)
      end
    end

    def method_missing(meth, *args, &block)
      if @cache.respond_to?(meth)
        @cache.send(meth, *args, &block)
      else
        super
      end
    end
  end
end
