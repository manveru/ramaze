#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'benchmark'

require 'mongrel'
require 'ramaze/tool/tidy'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module Mongrel
  class Configurator
    def log(msg)
      info :mongrel, msg
    end
  end
end

module Ramaze::Adapter
  class Mongrel < ::Mongrel::HttpHandler

    class << self
      def start host, port
        h = ::Mongrel::HttpServer.new host, port
        h.register "/", self.new

        h.run
      end

      def stop
      end
    end

    def process(request, response)
      @request, @response = request, response
      Global.mode == :benchmark ? bench_respond : respond
    end

    def bench_respond
      time = Benchmark.measure do
        respond
      end
      info "#{request} took #{time.real}s"
    end

    def respond
      @our_response = Dispatcher.handle(@request, @resopnse)
      code = @our_response.code || STATUS_CODE[:internal_server_error]
      @response.start(code) do |head, out|
        set_head head
        set_out  out
      end
    end

    def set_head head
      @our_response.head.each do |key, value|
        head[key] = value
      end
    end

    def set_out out
      our_out = 
        if Global.tidy and @our_response.content_type == 'text/html'
          Tool::Tidy.tidy(@our_response.out)
        else
          @our_response.out
        end
      out << our_out
    end

  end
end
