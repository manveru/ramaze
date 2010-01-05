require 'lokar'

module Ramaze
  module View
    module Lokar
      def self.call(action, string)
        compiled = View.compile(string){|s| ::Lokar.compile(s, action.view || __FILE__) }
        html = action.instance.instance_eval(&compiled).join

        return html, 'text/html'
      end
    end
  end
end
