#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'memcache'

module Ramaze
  class Cache

    # Cache based on the memcache library which utilizes the memcache-daemon to
    # store key/value pairs in namespaces.
    #
    # Please read the documentation of memcache-client for further methods.
    #
    # It is highly recommended to install memcache-client_extensions for
    # a bit of speedup and more functionality
    class MemCache
      include Cache::API

      # +:multithread+: May be turned off at your own risk.
      #    +:readonly+: You most likely want that to be false.
      #     +:servers+: Array containing at least one of:
      #                 MemCache::Server instance
      #                 Strings like "localhost", "localhost:11211", "localhost:11211:1"
      #                 That accord to "host:port:weight", only host is required.
      OPTIONS = {
        :multithread => true,
        :readonly    => false,
        :servers     => ['localhost:11211:1'],
      }

      # Connect to memcached
      def cache_setup(host, user, app, name)
        @namespace = [host, user, app, name].compact.join('-')
        options = {:namespace => @namespace}.merge(OPTIONS)
        servers = options.delete(:servers)
        @store = ::MemCache.new(servers, options)
      end

      # NOTE:
      #   * This will wipe out _all_ data in memcached, use with care.
      def cache_clear
        @store.flush_all
      rescue ::MemCache::MemCacheError => e
        Log.error(e)
        nil
      end

      def cache_delete(*keys)
        super{|key| @store.delete(key) }
      rescue ::MemCache::MemCacheError => e
        Log.error(e)
        nil
      end

      # NOTE:
      #   * We have no way of knowing whether the value really is nil, we
      #     assume you wouldn't cache nil and return the default instead.
      def cache_fetch(key, default = nil)
        value = @store[key]
        value.nil? ? default : value
      rescue ::MemCache::MemCacheError => e
        Log.error(e)
        nil
      end

      def cache_store(key, value, options = {})
        ttl = options[:ttl] || 0
        @store.set(key, value, ttl)
        value
      rescue ::MemCache::MemCacheError => e
        Log.error(e)
        nil
      end

      # statistics about usage
      def stats; @store.stats; end

      # current namespace
      def namespace; @store.namespace; end

      # switch to different namespace
      def namespace=(ns) @namespace = @store.namespace = ns; end

      # state of compression (true/false)
      def compression; @store.compression; end

      # turn compression on or off
      def compression=(bool); @store.compression = bool; end

      # For everything else that we don't care to document right now.
      def method_missing(*args, &block)
        @store.__send__(*args, &block)
      rescue ::MemCache::MemCacheError => e
        Log.error(e)
        nil
      end
    end
  end
end
