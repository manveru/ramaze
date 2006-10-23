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

    def parse_queries
      @get_query  = query_parse query_string rescue ''
      @post_query = query_parse body.read rescue ''
    end

    def query_parse str
      tmp = {}
      str.split('&').each do |pair|
        key, value = pair.split('=')
        tmp[key] = value
      end
      tmp
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

    def post?
      request_method == 'POST'
    end

    def get?
      request_method == 'GET'
    end

    def local?
      remote_addr == '127.0.0.1'
    end
  end
end
