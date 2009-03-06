require 'remarkably/engines/html'

module Ramaze
  module View
    module Remarkably
      def self.call(*args)
        ['text/html', render(*args)]
      end

      def self.render(action, string)
        string = transform_string(action, string) if action.view
        string.to_s
      end

      def self.transform_string(action, string)
        action.instance.instance_eval do
          args = action.params
          instance_eval(string)
        end
      end
    end
  end
end
