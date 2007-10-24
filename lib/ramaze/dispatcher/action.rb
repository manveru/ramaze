#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher

    # This dispatcher is responsible for relaying requests to Controller::handle
    # and filtering the results using FILTER.

    class Action

      # The response is passed to each filter by sending .call(response) to it.

      FILTER = OrderedSet.new(
        # Ramaze::Tool::Localize,
        # Ramaze::Tool::Tidy
      ) unless defined?(FILTER)

      class << self
        include Trinity

        # Takes path, asks Controller to handle it and builds a response on
        # success. The response is then passed to each member of FILTER for
        # post-processing.

        def process(path)
          Inform.info("Dynamic request from #{request.remote_addr}: #{path}")
          body = Controller.handle(path)
          response = Response.current.build(body)
          FILTER.inject(response){|r,f| f.call(r) }
        rescue Ramaze::Error => ex
          ex
        end
      end
    end
  end
end
