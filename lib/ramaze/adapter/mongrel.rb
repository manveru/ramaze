#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/adapter'

require 'mongrel'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module Ramaze::Adapter
  class Mongrel < Base
    class << self
      def start host, ports
        ports.map{|port| run_server(host, port) }.first
      end

      def run_server host, port
        server = ::Mongrel::HttpServer.new(host, port)
        server.register('/', ::Rack::Handler::Mongrel.new(self))
        server.run
      end

      def stop
      end

      def call(env)
        new.call(env)
      end
    end
  end
end
