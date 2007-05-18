#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Adapter
    class Base
      class << self
        def start host, ports
          ports.map do |port|
            Global.adapters.add(run_server(host, port))
            trap(Global.shutdown_trap){ Ramaze.shutdown }
          end
        end

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
    end
  end
end
