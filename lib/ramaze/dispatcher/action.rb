module Ramaze
  module Dispatcher
    class Action
      class << self
        def process(path)
          body = Controller.handle(path)
          Dispatcher.build_response(body)
        end
      end
    end
  end
end
