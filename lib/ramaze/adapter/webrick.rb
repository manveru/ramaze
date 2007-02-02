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

    #  request_uri.path

    def request_path
      request_uri.path
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
      if Global.inform_tags.include?(:benchmark)
        bench_process(request, response)
      else
        respond(response, Dispatcher.handle(request, response))
      end
    end

    # benchmark the current request/respond cycle and output the result
    # via Inform#debug (so make sure you got :debug in your Global.inform_tags
    #
    # It works as a simple wrapper with no other impacts on the rest
    # of the system.

    def bench_process(request, response)
      time = Benchmark.measure do
        response = respond(response, Dispatcher.handle(request, response))
      end
      debug "#{request} took #{time.real}s"
      response
    end

    # simply respond to a given request, #set_head and #set_out in the process
    # as well as setting the response-status (which is, in case it is not
    # given, 500, if nothing goes wrong it should be 200 or 302)

    def respond orig_response, response
      @response = orig_response
      if response
        set_head(response)
        set_out(response)
        @response.status = response.code || STATUS_CODE[:internal_server_error]
      end
      @response
    end

    # map the respond.head[key] to @response[key]

    def set_head(response)
      response.head.each do |key, val|
        @response[key] = val
      end
    end

    # set the body... in case you have Global.tidy = true it will run it
    # through Tool::Tidy.tidy first (if your content-type is text/html)

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
