require 'haml/engine'

module Ramaze
  module View
    module Haml
      def self.call(action, string)
        action.options[:filename] = (action.view || '(haml)')
        action.copy_variables
        haml = ::Haml::Engine.new(string.to_s, action.options)
        html = haml.to_html(action.instance, action.variables)

        return html, 'text/html'
      end
    end
  end
end
