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
      if Global.inform_tags.include?(:benchmark)
        time = Benchmark.measure{ respond env }
        info "request took #{time.real}s"
      else
        respond env
      end

      @response = Thread.current[:response]

      [@response.code, @response.head, self]
    end

    def respond env
      Dispatcher.handle(::Rack::Request.new(env), nil)
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
