require 'nagoro'
require 'ramaze/view/nagoro/render_partial'

module Ramaze
  module View
    module Nagoro
      DEFAULT_PIPES = [
        :Element, :Morph, :Include, :RenderPartial, :Instruction, :Compile
      ]

      OPTIONS = { :pipes => DEFAULT_PIPES }

      def self.call(action, string)
        action.options[:pipes] ||= OPTIONS[:pipes]
        action.options[:filename] = action.view
        action.options[:binding] = action.binding
        action.options[:variables] = action.variables

        html = ::Nagoro.render(string.to_s, action.options)

        return html, 'text/html'
      end
    end
  end
end
