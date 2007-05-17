#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rack'
require 'benchmark'

require 'rack/utils'
require 'ramaze/trinity'
require 'ramaze/tool/record'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module Ramaze
  STATUS_CODE = Rack::Utils::HTTP_STATUS_CODES.invert

  module Adapter
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
        request, response = Request.new(env), Response.new
        if filter = Global.record
          Record << request if filter[request]
        end
        Dispatcher.handle(request, response)
      end
    end # Base

    class << self # Adapter
      def startup options = {}
        start_adapter

        Timeout.timeout(3) do
          sleep 0.01 until Global.adapters.any?
        end

        trap(Global.shutdown_trap){ exit }
        Global.adapters.each{|a| a.join} unless Global.run_loose

      rescue SystemExit
        Ramaze.shutdown
      rescue Object => ex
        Inform.error(ex)
        Ramaze.shutdown
      end

      def start_adapter
        if adapter = Global.adapter
          host, ports = Global.host, Global.ports

          Inform.info("Adapter: #{adapter}, testing connection to #{host}:#{ports}")
          test_connections(host, ports)

          Inform.info("and we're running: #{host}:#{ports}")
          adapter.start(host, ports)
        else
          Global.adapters << :dummy
          Inform.warn("Seems like Global.adapter is turned off", "Continue without adapter.")
        end
      rescue LoadError => ex
        Inform.warn(ex, "Continue without adapter.")
      end

      def shutdown
        Global.adapters.each do |adapter|
          a = adapter[:adapter]
          a.shutdown if a.respond_to?(:shutdown)
        end
      end

      def test_connections host, ports
        return unless Global.test_connections

        ports.each do |port|
          unless test_connection(host, port)
            Inform.error("Cannot open connection on #{host}:#{port}")
            Ramaze.shutdown
          end
        end
      end

      def test_connection host, port
        Timeout.timeout(1) do
          TCPServer.open(host, port){ true }
        end
      rescue => ex
        Inform.error(ex)
        false
      end
    end # class << Adapter
  end # Adapter
end
