#          Copyright (c) 2008 Jeremy Evans  code@jeremyevans.net
# All files in this distribution are subject to the terms of the Ruby license.

require 'rack/handler/scgi'

module Ramaze
  module Adapter
    # Our Scgi adapter acts as wrapper for the Rack::Handler::SCGI.
    class Scgi < Base
      class << self

        # start SCGI in a new thread
        def run_server host, port
          Thread.new do
            Thread.current[:task] = :cgi
            Rack::Handler::SCGI.run(self, :Host=>host, :Port=>port)
          end
        end
      end
    end
  end
end
