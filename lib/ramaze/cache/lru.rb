#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Cache
    class LRU
      include Cache::API

      OPTIONS = {
        # expiration in seconds
        :expiration => nil,
        # maximum elements in the cache
        :max_count => 10000,
        # maximum total memory usage of the cache
        :max_total => nil,
        # maximum memory usage of an element of the cache
        :max_value => nil,
      }

      # Connect to localmemcache
      def cache_setup(host, user, app, name)
        @store = Ramaze::LRUHash.new(OPTIONS)
      end

      def cache_clear
        @store.clear
      end

      def cache_store(*args)
        super{|key, value| @store[key] = value }
      end

      def cache_fetch(*args)
        super{|key| @store[key] }
      end

      def cache_delete(*args)
        super{|key| @store.delete(key) }
      end
    end
  end
end
