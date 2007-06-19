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
    CACHES = {} unless defined?(CACHES)

    class << self

      # Initializes the Cache for the general caches Ramaze uses.
      # Cache#startup is called by Ramaze#startup, when initializing the
      # Ramaze.trait(:essentials).

      def startup(options)
        Cache.add :compiled, :actions, :patterns, :resolved, :shield
      end

      # This will define a method to access a new cache directly over
      # sinleton-methods on Cache

      def add *keys
        keys.each do |key|
          CACHES[key] = new
          self.class.class_eval do
            define_method(key){ CACHES[key] }
          end
        end
        Inform.debug("Added caches for: #{keys.join(', ')}")
      end

    end

    # Initializes the cache, defined by Global.cache

    def initialize(cache = Global.cache)
      @cache = cache.new
    end

    def [](key)
      @cache[key.to_s]
    end

    def []=(key, value)
      @cache[key.to_s] = value
    end

    # deletes the keys of each argument passed from Cache instance.

    def delete(*args)
      args.each do |arg|
        @cache.delete(arg.to_s)
      end
    end

    # method_missing tries to handle undefined method calls. Should it fail,
    # it passes it to super for proper error handling.

    def method_missing(meth, *args, &block)
      if @cache.respond_to?(meth)
        @cache.send(meth, *args, &block)
      else
        super
      end
    end
  end
end
