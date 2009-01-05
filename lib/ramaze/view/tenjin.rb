require 'tenjin'

module Innate
  module View
    module Tenjin
      module_function

      def render(action, string = nil)
        context = build_context(action)

        template = ::Tenjin::Template.new
        template.convert(string || action.view)

        template.render(context)
      end

      def build_context(action)
        hash = action.variables
        instance = action.instance

        # action_binding = action.binding
        instance.instance_variables.each do |iv|
          iv = iv.to_s
          hash[iv[1..-1]] = instance.instance_variable_get(iv)
        end

        hash
      end
    end
  end
end
