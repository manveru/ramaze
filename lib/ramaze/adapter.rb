#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rack'
require 'timeout'
require 'benchmark'

require 'rack/utils'
require 'ramaze/trinity'
require 'ramaze/tool/record'
require 'ramaze/adapter/base'

# for OSX compatibility
Socket.do_not_reverse_lookup = true

module Ramaze
  STATUS_CODE = Rack::Utils::HTTP_STATUS_CODES.invert

  module Adapter
    class << self
      def startup options = {}
        start_adapter

        Timeout.timeout(3) do
          sleep 0.01 until Global.adapters.list.any?
        end

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
        else # run dummy
          Global.adapters.add Thread.new{ sleep }
          Inform.warn("Seems like Global.adapter is turned off", "Continue without adapter.")
        end
      rescue LoadError => ex
        Inform.warn(ex, "Continue without adapter.")
      end

      def shutdown
        Timeout.timeout(1) do
          Global.adapters.list.each do |adapter|
            a = adapter[:adapter]
            a.shutdown if a.respond_to?(:shutdown)
          end
        end
      rescue Timeout::Error
        Global.adapters.list.each{|a| a.kill!}
        exit!
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
    end
  end
end
