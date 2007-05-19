#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Adapter

    # This class is holding common behaviour for its subclasses.

    class Base
      class << self

        # For the specified host and for all given ports call run_server and
        # add the returned thread to the Global.adapters ThreadGroup.
        # Afterwards adds a trap for the value of Global.shutdown_trap which
        # calls Ramaze.shutdown when triggered (usually by SIGINT).

        def start host, ports
          ports.each do |port|
            Global.adapters.add(run_server(host, port))
            trap(Global.shutdown_trap){ Ramaze.shutdown }
          end
        end

        # Does nothing

        def stop
          Inform.debug("Stopping #{self.class}")
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
end
