#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
require 'memcache'

module Ramaze
  class MemcachedCache

    # Create a new MemcachedCache with host, port and a namespace that defaults
    # to 'ramaze'
    #
    # For your own usage you should use another namespace.

    def initialize(host = 'localhost', port = '11211', namespace = 'ramaze')
      @cache = MemCache.new("#{host}:#{port}", :namespace => namespace)
    end

    # please read the documentation of memcache-client for further methods.
    # also, it is highly recommended to install memcache-client_extensions
    # for a bit of speedup and more functionality
    # Some examples:
    #
    # [key]                       #=> get a key
    # [key] = value               #=> set a key
    # delete(key)                 #=> delete key
    # set_many :x => :y, :n => :m #=> set many key/value pairs
    # get_hash :x, :y             #=> return a hash with key/value pairs
    # stats                       #=> get some statistics about usage
    # namespace                   #=> get the current namespace
    # namespace = 'ramaze'        #=> set a different namespace ('ramaze' is default)
    # flush_all                   #=> flush the whole cache (deleting all)
    # compression                 #=> see if compression is true/false
    # compression = false         #=> turn off compression (it's by default true)

    def method_missing(*args, &block)
      @cache.__send__(*args, &block)
    rescue MemCache::MemCacheError => e
      Ramaze::Inform.error e.to_s
      nil
    end

    # out of some reason MemCache sometimes doesn't respond to
    # get_multi, have to investigate this further.
    #
    # for now, i'll just use the dumbed down version and ask it
    # whether it implements this functionality or not.

    def get_multi(*keys)
      if @cache.respond_to?(:get_multi)
        @cache.get_multi(*keys)
      else
        @cache.get_hash(*keys)
      end
    end

    # same as get_multi, but returns only the values (in order)

    def values_at(*keys)
      get_multi(*keys).values_at(*keys)
    end
  end
end

# add the MemCache#clear method

class MemCache
  def clear
    raise MemCacheError, "Update of readonly cache" if @readonly

    @servers.each do |server|
      server.flush_all
    end
  end

  class Server
    def flush_all
      @mutex.lock if @multithread

      socket.write "flush_all\r\n"
    ensure
      @mutex.unlock if @multithread
    end
  end
end
