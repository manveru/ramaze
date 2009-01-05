require 'sass/engine'

module Ramaze
  module View
    module Sass
      def self.render(action, string = nil)
        string ||= action.view
        sass = ::Sass::Engine.new(string, action.options)
        sass.to_css
      end
    end
  end
end
