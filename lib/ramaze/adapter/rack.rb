require 'rack'
require 'ramaze/tool/tidy'

$: << "/home/chris/src/mongrel/lib"
require 'mongrel'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module Ramaze::Adapter

  class Rack

    class << self
      def start host, ports
        ports.map{|port| run_server(host, port) }.first
      end

      def run_server host, port
        p [:start, host, port]
        server = Mongrel::HttpServer.new(host, port)
        server.register('/', ::Rack::Handler::Mongrel.new(self))
        server.run
      end
      
      def stop
      end

      def call(env)
        new.call(env)
      end
    end

    # Process a request and give a response, based on the objects
    # Mongrel gives it.
    #
    # if the Global.inform_tags include :benchmark it will run #bench_process,
    # otherwise simply #respond.

    class MyRequest
      def initialize(env)
        @env = env
      end

      def params
        @env
      end

#      def method_missing(name, *a)
#        p [:req, name, *a]
#        @env[name.to_s.upcase]
#      end
    end

    def call(env)
      Dispatcher.handle(MyRequest.new(env), nil)
      @response = Thread.current[:response]

      [@response.code, @response.head, self]
    end

    def each
      out = @response.out

      if out.respond_to?(:read)
        until out.eof?
          yield out.read(1024)
        end
      else
        yield out
      end
    end

    def foo
      send_file = o_response.out.respond_to?(:to_hash)

      if send_file
        file = o_response.out[:send_file]
        @response.start(200) do |head, out|
          head['Content-Type'] = 'text/plain'
          stat = File.stat(file)
          @response.send_status(stat.size)
          @response.send_header
          @response.send_file(file)
        end
      else
        code = o_response.code || STATUS_CODE[:internal_server_error]

        @response.start(code) do |head, out|
          set_head head
          set_out  out
        end
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
