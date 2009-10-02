require 'erector'

module Ramaze
  module View
    module Erector
     def self.call(action, string)
        return string, 'text/html' unless action.view

        markup = <<-EOS
          _controller = self
          html = ::Erector.inline do
            # copy instance variables into Erector context
            _controller.instance_variables.each do |v|
              instance_variable_set(v, _controller.instance_variable_get(v))
            end
            #{string}
          end.to_s
        EOS

        html = action.instance.instance_eval(markup)

        return html, 'text/html'
      end
    end
  end
end
