require 'ramaze/gestalt'

module Ramaze
  module View
    module Gestalt
      def self.call(action, string)
        string = action.instance.instance_eval(string) if action.view
        html = [string].join

        return html, 'text/html'
      end
    end
  end
end
