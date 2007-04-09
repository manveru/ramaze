#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rack'
require 'benchmark'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module Ramaze::Adapter
  class Base
    class << self
      def stop
        Informer.debug "Stopping #{self.class}"
      end

      def call(env)
        new.call(env)
      end
    end

    def call(env)
      if Ramaze::Global.inform_tags.include?(:benchmark)
        time = Benchmark.measure{ respond env }
        info "request took #{time.real}s"
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
      request, response = Ramaze::Request.new(env), Ramaze::Response.new
      Ramaze::Dispatcher.handle(request, response)
    end
  end
end
