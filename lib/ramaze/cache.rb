#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/cache/memory'

module Ramaze
  autoload :YAMLStoreCache, "ramaze/cache/yaml_store.rb"
  autoload :MemcachedCache, "ramaze/cache/memcached.rb"

  # This is the wrapper of all caches, providing mechanism
  # for switching caching from one adapter to another.

  class Cache
    def initialize(cache = Global.cache)
      @cache = cache.new
    end

    def [](key)
      @cache[key.to_s]
    end

    def []=(key, value)
      @cache[key.to_s] = value
    end

    def clear
      @cache.clear
    end

    def delete(*args)
      args.each do |arg|
        @cache.delete(arg.to_s)
      end
    end
  end
end
