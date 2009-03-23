require 'amrita2'

module Ramaze
  module View
    module Amrita2
      def self.call(action, string)
        # prepare
        action.instance.extend(::Amrita2::Runtime) # if data.kind_of?(Binding)

        # setup
        template = ::Amrita2::Template.new(string)

        data = action.instance.instance_variable_get('@data')
        binding = action.instance.instance_variable_get('@binding') || action.binding
        html = template.render_with(data, binding)

        return html, 'text/html'
      end
    end
  end
end
