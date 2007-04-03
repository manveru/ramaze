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

      @response = Thread.current[:response]

      [@response.status, @response.header, self]
    end

    def respond env
      Ramaze::Dispatcher.handle(::Rack::Request.new(env), ::Rack::Response.new)
    end

    def each
      body = @response.body

      if body.respond_to?(:read)
        until body.eof?
          yield body.read(1024)
        end
      else
        if Global.tidy
          require 'ramaze/tool/tidy'
          yield Ramaze::Tool::Tidy.tidy(body)
        else
          yield body
        end
      end
    end
  end
end
