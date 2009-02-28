require 'haml/util'
require 'sass/engine'

module Ramaze
  module View
    module Sass
      def self.render(action, string)
        Current.response['Content-Type'] = 'text/css'

        options = action.options
        if sass_options = action.instance.ancestral_trait[:sass_options]
          options = options.merge(sass_options)
        end

        sass = ::Sass::Engine.new(string, options)
        sass.to_css
      end
    end
  end
end
