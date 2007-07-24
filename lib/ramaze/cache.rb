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

    attr_accessor :cache

    class << self

      # Initializes the Cache for the general caches Ramaze uses.
      # Cache#startup is called by Ramaze#startup, when initializing the
      # Ramaze.trait(:essentials).

      def startup(options)
        Cache.add :compiled, :actions, :patterns, :resolved, :shield
      end

      # This will define a method to access a new cache directly over
      # singleton-methods on Cache.
      #---
      # The @cache_name is internally used for caches which do not save
      # different caches in different namespaces, for example memcached.
      #+++

      def add *keys
        keys.each do |key|
          CACHES[key] = new
          CACHES[key].instance_variable_set("@cache_name", key)
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
      @cache["#{@cache_name}:#{key}"]
    end

    def []=(key, value)
      @cache["#{@cache_name}:#{key}"] = value
    end

    # deletes the keys of each argument passed from Cache instance.
    def delete(*args)
      args.each do |arg|
        @cache.delete("#{@cache_name}:#{arg}")
      end
    end

    # Empty this cache
    def clear
      @cache.clear
    end

    # Answers with value for each key.
    def values_at(*keys)
      @cache.values_at(*keys.map {|key| "#{@cache_name}:#{key}" })
    end
  end
end
