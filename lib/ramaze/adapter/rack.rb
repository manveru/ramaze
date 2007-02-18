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

    def call(env)
      Dispatcher.handle(::Rack::Request.new(env), nil)
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
  end
end
