require 'amrita2'

module Ramaze
  module View
    module Amrita2
      def self.call(*args)
        ['text/html', render(*args)]
      end

      def self.render(action, string)
        # prepare
        action.copy_variables
        action.instance.extend(::Amrita2::Runtime) # if data.kind_of?(Binding)

        # setup
        template = ::Amrita2::Template.new(string)

        data = action.instance.instance_variable_get('@data')
        binding = action.instance.instance_variable_get('@binding') || action.binding

        template.render_with(data, binding)
      end
    end
  end
end
