require 'haml/util'
require 'haml/engine'

module Ramaze
  module View
    module Haml
      def self.call(action, string)
        options = action.options

        if haml_options = action.instance.ancestral_trait[:haml_options]
          options = options.merge(haml_options)
        end

        action.options[:filename] = (action.view || '(haml)')
        haml = View.compile(string){|s| ::Haml::Engine.new(s, options) }
        html = haml.to_html(action.instance, action.variables)

        return html, 'text/html'
      end
    end
  end
end
