require 'amrita2'

module Ramaze
  module View
    module Amrita2
      def self.render(action, string = action.view)
        template = ::Amrita2::Template.new(string)
        data = action.variables[:data] || {}
        action.instance.extend(::Amrita2::Runtime) if data.kind_of?(Binding)
        template.render_with(data)
      end
    end
  end
end
