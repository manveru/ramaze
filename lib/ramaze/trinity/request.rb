#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'cgi'
require 'tmpdir'
require 'digest/md5'

module Ramaze

  # This class is used for processing the information coming in from a request
  # to the dispatcher, it takes the original request-object, processes it and
  # is later available in the controller or as Thread.current[:request]
  #
  # Please note that the implementation is lacking performance and security
  # in favor of simplicity. Hopefully I (or some CGI-guru) will come along
  # and implement this properly, until then consider it unsafe, but functional.
  #
  # Most information you will need is in the #params, which is a compound of
  # all the information available from POST, GET, DELETE and PUT.

  class Request
    #attr_accessor :request, :post_query, :get_query, :puts_query, :get_query

    class << self

      # get the current request out of Thread.current[:request]
      #
      # You can call this from everywhere with Ramaze::Request.current

      def current
        Thread.current[:request]
      end
    end

    # create a new instance of Request, takes the original request-object
    # and runs #parse_queries to extract/process the information inside

    def initialize request = {}
      @request = request
    end

    def [](key)
      @request.params[key]
    end

    def []=(key, value)
      @request.params[key] = value
    end

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
