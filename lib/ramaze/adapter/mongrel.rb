#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'benchmark'

require 'mongrel'
require 'ramaze/tool/tidy'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module Mongrel
  class Configurator

    # the default for log is Informer#<< like WEBrick

    def log(msg)
      Informer << "Mongrel: #{msg}"
    end
  end
end

module Ramaze::Adapter
  class Mongrel < ::Mongrel::HttpHandler

    class << self

      # create a new instance of Mongrel::HttpServer and run it
      # mongrel will give us a new Thread back.

      def start host, ports
        ports.each do |port|
          run_server host, port
        end
      end

      def run_server host, port
        h = ::Mongrel::HttpServer.new host, port
        h.register "/", self.new

        h.run
      end

      # doesn't do anything, for the time being.

      def stop
        debug "stopping Mongrel"
      end
    end

    # Process a request and give a response, based on the objects
    # Mongrel gives it.
    #
    # if the Global.inform_tags include :benchmark it will run #bench_process,
    # otherwise simply #respond.

    def process(request, response)
      @request, @response = request, response
      Global.inform_tags.include?(:benchmark) ? bench_respond : respond
    end

    # benchmark the current request/respond cycle and output the result
    # via Inform#debug (so make sure you got :debug in your Global.inform_tags
    #
    # It works as a simple wrapper with no other impacts on the rest
    # of the system.

    def bench_respond
      time = Benchmark.measure do
        respond
      end
      info "request took #{time.real}s"
    end

    # simply respond to a given request, #set_head and #set_out in the process
    # as well as setting the response-status (which is, in case it is not
    # given, 500, if nothing goes wrong it should be 200 or 302)

    def respond
      @our_response = Dispatcher.handle(@request, @response)
      code = @our_response.code || STATUS_CODE[:internal_server_error]
      @response.start(code) do |head, out|
        set_head head
        set_out  out
      end
    end

    # map the respond.head[key] to @response[key]

    def set_head head
      @our_response.head.each do |key, value|
        head[key] = value
      end
    end

    # set the body... in case you have Global.tidy = true it will run it
    # through Tool::Tidy.tidy first (if your content-type is text/html)

    def set_out out
      our_out =
        if Global.tidy and @our_response.content_type == 'text/html'
          Tool::Tidy.tidy(@our_response.out)
        else
          @our_response.out
        end
      out << our_out
    end

  end
end
