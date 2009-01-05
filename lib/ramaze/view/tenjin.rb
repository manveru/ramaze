require 'tenjin'

module Ramaze
  module View
    module Tenjin
      def self.render(action, string = action.view)
        context = build_context(action)

        template = ::Tenjin::Template.new
        template.convert(string)

        template.render(context)
      end

      def self.build_context(action)
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
