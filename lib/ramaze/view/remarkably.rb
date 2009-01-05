require 'remarkably/engines/html'

module Ramaze
  module View
    module Remarkably
      def self.render(action, string)
        action.instance.instance_eval{
          args = action.params
          instance_eval(string)
        }.to_s
      end
    end
  end
end
