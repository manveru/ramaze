require 'thin'
require 'ramaze/adapter'
require 'rack/handler/thin'

module Ramaze
  module Adapter

    class Thin < Base
      class << self

        # start server on given host and port.
        def run_server host, port
          server = ::Thin::Server.new(host, port, self)
          server.silent = true
          server.timeout = 3
          server.start

          thread = Thread.new{ server.listen! }
          thread[:adapter] = server
          thread
        end
      end
    end
  end
end
