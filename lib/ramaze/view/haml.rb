require 'haml/util'
require 'haml/engine'

module Ramaze
  module View
    module Haml
      def self.call(action, string)
        action.options[:filename] = (action.view || '(haml)')
        haml = View.compile(string){|s| ::Haml::Engine.new(s, action.options) }
        html = haml.to_html(action.instance, action.variables)

        return html, 'text/html'
      end
    end
  end
end
