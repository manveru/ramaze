require 'haml/util'
require 'haml/engine'

module Ramaze
  module View
    module Haml
      def self.call(action, string)
        return render(ation, string), 'text/html'
      end

      def self.render(action, string)
        haml = compile(action, string)
        haml.to_html(action.instance, action.variables)
      end

      def self.compile(action, string)
        action.options[:filename] = (action.view || '(haml)')
        ::Haml::Engine.new(string.to_s, action.options)
      end
    end
  end
end
