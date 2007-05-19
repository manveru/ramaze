#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/adapter'
require 'mongrel'
require 'rack/handler/mongrel'

module Ramaze
  module Adapter
    class Mongrel < Base
      class << self
        def run_server host, port
          server = ::Mongrel::HttpServer.new(host, port)
          server.register('/', ::Rack::Handler::Mongrel.new(self))
          thread = server.run
          thread[:adapter] = server
          thread
        end
      end
    end
  end
end
