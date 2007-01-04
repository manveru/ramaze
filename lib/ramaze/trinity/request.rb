#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'cgi'

module Ramaze
  class Request
    attr_accessor :request
    def initialize request = {}
      @request = request
      parse_queries
    end

    def method_missing meth, *args, &block
      if value = @request.params[meth.to_s.upcase] rescue false
        value
      else
        @request.send(meth, *args, &block)
      end
    end

    def params
      (@get_query || {}).merge(@post_query || {})
    end

    # this parses stuff like post-requests (very untested)
    # and also ?foo=bar stuff (get-query)
    # WEBrick uses body as a streaming-object, so we have to #read.
    # Mongrel has a normal string as body, we just call to_s in case
    # it's no POST

    def parse_queries
      if get?
        @get_query  = query_parse(query_string) rescue {}
      elsif post?
        @post_query = query_parse(body.respond_to?(:read) ? body.read : body)
      end
    end

    def query_parse str
      str = str.split('?').last.to_s rescue ''
      hash = CGI.parse(str)
      hash.each do |key, values|
        key = CGI.unescape(key)
        values = values.map{|v| CGI.unescape(v)}
        hash[key] = values.size == 1 ? values.first : values
      end
      hash
    end

    def [](key)
      @post_query[key]
    end

    def []=(key, value)
      @post_query[key] = value
    end

    def post_query
      @post_query
    end

    def get_query
      @get_query
    end

    def get?()    request_method == 'GET'    end
    def post?()   request_method == 'POST'   end
    def put?()    request_method == 'PUT'    end
    def delete?() request_method == 'DELETE' end

    def local?
      remote_addr == '127.0.0.1'
    end
  end
end
