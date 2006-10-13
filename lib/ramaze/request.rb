module Ramaze
  class Request
    attr_accessor :request
    def initialize request = {}
      @request = request
      parse_query
    end

    def method_missing meth, *args, &block
      if value = @request.params[meth.to_s.upcase]
        value
      else
        @request.send(meth, *args, &block)
      end
    end

    def parse_query
      @query = {}
      query_string.split('&').each do |pair|
        key, value = pair.split('=')
        @query[key] = value
      end
    rescue NoMethodError => ex
      @query
    end

    def query
      @query
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
