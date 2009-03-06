require 'nagoro'
require 'ramaze/view/nagoro/render_partial'

module Ramaze
  module View
    module Nagoro
      DEFAULT_PIPES = [
        :Element, :Morph, :Include, :RenderPartial, :Instruction, :Compile
      ]

      OPTIONS = { :pipes => DEFAULT_PIPES }

      def self.call(*args)
        p :call => args
        ['text/html', render(*args)]
      end

      def self.render(action, string)
        action.options[:pipes] ||= OPTIONS[:pipes]
        action.options[:filename] = action.view
        action.options[:binding] = action.binding
        action.options[:variables] = action.variables

        ::Nagoro.render(string.to_s, action.options)
      end
    end
  end
end
