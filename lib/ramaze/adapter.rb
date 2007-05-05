#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rack'
require 'benchmark'

require 'ramaze/trinity'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

class Rack::Request
  include Ramaze::Request
end

class Rack::Response
  include Ramaze::Response
end

module Ramaze::Adapter
  class Base
    class << self
      def stop
        Inform.debug("Stopping #{self.class}")
      end

      def call(env)
        new.call(env)
      end
    end

    def call(env)
      if Ramaze::Global.benchmarking
        time = Benchmark.measure{ respond env }
        Inform.debug("request took #{time.real}s")
      else
        respond env
      end

      finish
    end

    def finish
      response = Thread.current[:response]

      response.finish
    end

    def respond env
      request, response = Rack::Request.new(env), Rack::Response.new
      Ramaze::Dispatcher.handle(request, response)
    end
  end
end
