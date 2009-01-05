require 'liquid'

module Ramaze
  module View
    module Liquid
      def self.render(action, string = nil)
        template = ::Liquid::Template.parse(string)
        data = action.variables[:data] || {}
        template.render(data, options)
      end
    end
  end
end
