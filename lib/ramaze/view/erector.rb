require 'erector'

module Ramaze
  module View
    module Erector
      extend ::Erector::Mixin

      def self.call(action, string)
        return string, 'text/html' unless action.view

        controller = action.instance

        html = ::Erector.inline do
          # copy instance variables into Erector context
          controller.instance_variables.each do |v|
            instance_variable_set(v, controller.instance_variable_get(v))
          end

          eval(string)
        end.to_s

        return html, 'text/html'
      end
    end
  end
end
