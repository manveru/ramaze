#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'cgi'
require 'webrick'
require 'benchmark'

require 'ramaze/tool/tidy'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module WEBrick
  class HTTPRequest
    attr_accessor :params

    #  request_uri.path

    def request_path
      request_uri.path
    end

    #  peeraddr.last

    def remote_addr
      peeraddr.last
    end

    # the headers of the current request.

    def headers
      return @headers if @headers
      @headers = meta_vars.merge(header)
      @headers.each do |key, value|
        @headers.delete(key)
        @headers[key.upcase] = value
      end
      @headers
    end

  end

  module HTTPServlet
    class ProcHandler
      alias do_PUT do_GET
      alias do_DELETE do_GET
    end
  end
end

module Ramaze::Adapter
  class Webrick
    class << self

      # The method to start a new webrick-adapter on the specified
      # host/ports, will return the first of the started adapters.
      #
      # sets up the default handler for the request/response cycle.

      def start host, ports
        handler = lambda do |request, response|
          self.new.process(request, response)
        end

        ports.map{|port| run_server(host, port, handler) }.first
      end

      # run the actual server on host/port with the handler given.
      # passes WEBrick::HTTPServlet the default options and starts
      # it up in a new Thread, setting Thread.current[:adapter]

      def run_server host, port, handler
        options = {
          :Port => port,
          :BindAddress => host,
          :Logger => Informer,
          :AccessLog => [
            [Informer, WEBrick::AccessLog::COMMON_LOG_FORMAT],
            [Informer, WEBrick::AccessLog::REFERER_LOG_FORMAT]
          ]
        }

        server = WEBrick::HTTPServer.new(options)
        server.mount('/', WEBrick::HTTPServlet::ProcHandler.new(handler))

        Thread.new do
          Thread.current[:task] = :webrick
          Thread.current[:adapter] = server
          server.start
        end
      end

      # doesn't do anything, for the time being.

      def stop
        debug "stopping WEBrick"
      end
    end

    # process a request and give a response, based on the objects
    # WEBrick gives it.
    #
    # if the Global.inform_tags include :benchmark it will run #bench_process,
    # otherwise simply #respond.

    def process request, response
      @webrick_request, @webrick_response = request, response
      if Global.inform_tags.include?(:benchmark)
        bench_dispatcher
      else
        call_dispatcher
      end
      respond
      @webrick_response
    end

    # benchmark the current request/respond cycle and output the result
    # via Inform#debug (so make sure you got :debug in your Global.inform_tags
    #
    # It works as a simple wrapper with no other impacts on the rest
    # of the system.

    def bench_dispatcher(request, response)
      time = Benchmark.measure do
      end
      debug "#{request} took #{time.real}s"
    end

    def call_dispatcher
      Dispatcher.handle @webrick_request, @webrick_response
    end

    # simply respond to a given request, #set_head and #set_out in the process
    # as well as setting the response-status (which is, in case it is not
    # given, 500, if nothing goes wrong it should be 200 or 302)

    def respond
      @response = Thread.current[:response]
      code, out, head = @response.code, @response.out, @response.head

      if @response
        @response.head.each do |key, val|
          @webrick_response[key] = val
        end
        @webrick_response.status = @response.code || STATUS_CODE[:internal_server_error]
        if out.respond_to?(:read)
          until out.eof?
            @webrick_response.body << out.read(1024)
          end
        else
          @webrick_response.body << out
        end
      end
    end
  end
end
