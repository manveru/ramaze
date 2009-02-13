require 'haml/engine'

module Ramaze
  module View
    module Haml
      def self.render(action, string = nil)
        string ||= action.view
        action.options[:filename] ||= (action.view || '(haml)')
        action.copy_variables
        haml = ::Haml::Engine.new(string.to_s, action.options)
        haml.to_html(action.instance, action.variables)
      end
    end
  end
end
