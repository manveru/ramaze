#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
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

        def start host, port
          Global.server = run_server(host, port)
          trap(Global.shutdown_trap){ Ramaze.shutdown }
        end

        # Does nothing

        def stop
          Log.debug("Stopping #{self.class}")
        end

        # This is called by Rack with the usual env, subsequently calls
        # ::respond with it.
        #
        # The method itself acts just as a wrapper for benchmarking and then
        # calls .finish on the current response after ::respond has finished.

        def call(env)
          returned = nil
          if Global.benchmarking
            require 'benchmark'
            time = Benchmark.measure{ returned = respond(env) }
            Log.debug('request took %.5fs [~%.0f r/s]' % [time.real, 1.0/time.real])
          else
            returned = respond env
          end
          returned
        end

        # Initializes Request with env and an empty Response. Records the
        # request into Ramaze::Record if Global.record is true.
        # Then goes on and calls Dispatcher::handle with request and response.

        def respond env
          if Global.server == Thread.current
            Thread.new{ Current.call(env) }.value
          else
            Current.call(env)
          end
        end
      end
    end
  end
end
