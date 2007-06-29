#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher
    class Action

      # The response is passed to each filter by sending .call(response) to it.

      FILTER = [
        # Ramaze::Tool::Localize,
        # Ramaze::Tool::Tidy
      ]

      class << self
        def process(path)
          body = Controller.handle(path)
          response = Dispatcher.build_response(body)
          FILTER.inject(response){|r,f| f.call(r) }
        rescue Ramaze::Error => ex
          ex
        end
      end
    end
  end
end
