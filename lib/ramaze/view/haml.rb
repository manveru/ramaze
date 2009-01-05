require 'haml/engine'

module Innate
  module View
    module Haml
      module_function

      def render(action, string = nil)
        string ||= action.view
        action.options[:filename] ||= (action.view || '(haml)')
        haml = ::Haml::Engine.new(string.to_s, action.options)
        haml.to_html(action.instance, action.variables)
      end
    end
  end
end
