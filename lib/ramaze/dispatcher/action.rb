module Ramaze
  module Dispatcher
    class Action
      def initialize path
        @path = path
      end

      def process
        body = Controller.handle(@path)
        Dispatcher.build_response(body)
      end
    end
  end
end
