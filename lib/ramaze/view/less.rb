require 'less'

module Ramaze
  module View
    module Less
      def self.call(action, string)
        options = action.options

        if sass_options = action.instance.ancestral_trait[:sass_options]
          options = options.merge(sass_options)
        end

        less = View.compile(string){|s| ::Less::Engine.new(s) }
        css = less.to_css

        return css, 'text/css'
      end
    end
  end
end
