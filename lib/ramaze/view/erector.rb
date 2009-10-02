require 'erector'

module Ramaze
  module View
    module Erector
     def self.call(action, string)
        return string, 'text/html' unless action.view

        html = ::Erector.inline do
          # copy instance variables into Erector context
          action.instance.instance_variables.each do |v|
            instance_variable_set(v, action.instance.instance_variable_get(v))
          end

          eval(string)
        end.to_s

        return html, 'text/html'
      end
    end
  end
end
