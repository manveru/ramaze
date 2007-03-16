#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'cgi'
require 'tmpdir'
require 'digest/md5'

module Ramaze

  # The purpose of this class is to act as a simple wrapper for Rack::Request
  # and provide some convinient methods for our own use.

  class Request
    class << self

      # get the current request out of Thread.current[:request]
      #
      # You can call this from everywhere with Ramaze::Request.current

      def current
        Thread.current[:request]
      end
    end

    # create a new instance of Request, takes the original Rack::Request
    # instance

    def initialize request = {}
      @request = request
    end

    # shortcut for request.params[key]

    def [](key)
      params[key]
    end

    # shortcut for request.params[key] = value

    def []=(key, value)
      params[key] = value
    end

    # like Hash#values_at

    def values_at(*keys)
      keys.map{|key| params[key] }
    end

    # the referer of the client or '/'

    def referer
      @request.env['HTTP_REFERER'] || '/'
    end

    # you can access the original @request via this method_missing,
    # first it tries to match your method with any of the HTTP parameters
    # then, in case that fails, it will relay to @request

    def method_missing meth, *args, &block
      @request.send(meth, *args, &block)
    rescue
      @request.env[meth.to_s.upcase]
    end
  end
end
