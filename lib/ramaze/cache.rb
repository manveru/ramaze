#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'memcache'

module Ramaze
  MemoryCache = Hash

  class MemcachedCache
    def initialize(host = 'localhost', port = '11211', namespace = 'ramaze')
      @cache = MemCache.new("#{host}:#{port}", :namespace => namespace)
    end

    def [](key)
      @cache.get(key)
    end

    def []=(key, value)
      expiry = 0
      @cache.set(key, value, expiry)
    end

    def delete(key)
      @cache.delete(key)
    end

    def get_multi(*keys)
      @cache.get_multi(*keys)
    end

    def values_at(*keys)
      get_multi(*keys).values_at(*keys)
    end
  end

  Cache = MemoryCache.new
end
