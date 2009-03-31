require 'haml/util'
require 'sass/engine'

module Ramaze
  module View
    module Sass
      def self.call(action, string)
        options = action.options

        if sass_options = action.instance.ancestral_trait[:sass_options]
          options = options.merge(sass_options)
        end

        sass = ::Sass::Engine.new(string, options)
        css = sass.to_css

        return css, 'text/css'
      end
    end
  end
end
