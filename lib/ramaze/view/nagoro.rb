require 'nagoro'

module Innate
  module View
    module Nagoro
      module_function

      def render(action, string = nil)
        string ||= action.view
        action.options[:filename] ||= action.view
        # action.options[:pipes] ||= []
        action.options[:binding] = action.instance.__send__(:binding)
        action.options[:variables] = action.variables

        ::Nagoro.render(string.to_s, action.options)
      end
    end
  end
end
