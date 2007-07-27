#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  if ENV['SWIFT']
    require 'swiftcore/swiftiplied_mongrel'
    Inform.debug "Using Swiftiplied Mongrel"
  elsif ENV['EVENT']
    require 'swiftcore/evented_mongrel'
    Inform.debug "Using Evented Mongrel"
  else
    require 'mongrel'
  end

  require 'ramaze/adapter'
  require 'rack/handler/mongrel'

  module Adapter

    # Our Mongrel adapter acts as wrapper for the Rack::Handler::Mongrel.
    class Mongrel < Base
      class << self

        # start server on given host and port.
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
