require 'cgi'
require 'webrick'
require 'benchmark'

require 'ramaze/tool/tidy'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module WEBrick
  class HTTPRequest
    attr_accessor :params

    def request_path
      request_uri.path
    end

    def remote_addr
      peeraddr.last
    end

    def request_path
      request_uri.path
    end

    def get?
      not post?
    end

    def post?
      @request_method == 'POST'
    end

    def headers
      return @headers if @headers
      @headers = meta_vars.merge(header)
      @headers.each do |key, value|
        @headers.delete(key)
        @headers[key.upcase] = value
      end
      @headers
    end

    def params
      @params ||= parse_params
    end

    def parse_params to_parse = body.to_s
      params = {}
      [body, query_string].each do |chunk|
        chunk.to_s.split('&').each do |pair|
          key, value = pair.split('=').map{|e| CGI.unescape(e)}
          params[key] = value
        end
      end
      params
    end
  end
end

module Ramaze::Adapter
  class Webrick
    def self.start host, port
      # TODO
      # - add host
      # - implement graceful shutdown

      handler = lambda do |request, response|
        # FIXME: urgent
        # request = process_request(request)
        self.new.process(request, response)
      end

      server = WEBrick::HTTPServer.new(:Port => port, :BindAddress => host)
      server.mount('/', WEBrick::HTTPServlet::ProcHandler.new(handler))
      Thread.new do
        server.start
      end
    end

    def process request, response
      if Global.mode == :benchmark
        bench_process(request, response)
      else
        respond(response, Dispatcher.handle(request, response))
      end
    end

    def bench_process(request, response)
      time = Benchmark.measure do
        response = respond(response, Dispatcher.handle(request, response))
      end
      info "#{request} took #{time.real}s"
      response
    end

    def respond orig_response, response
      @response = orig_response
      if response
        set_head(response)
        set_out(response)
      end
      @response
    end

    def process_request(request)
      request.parse_params
      request
    end

    def set_head(response)
      response.head.each do |key, val|
        @response[key] = val
      end
    end

    def set_out response
      @response.body =
        if Global.tidy and response.content_type == 'text/html'
          Tool::Tidy.tidy(response.out)
        else
          response.out
        end
    end
  end
end
