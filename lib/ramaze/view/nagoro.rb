require 'nagoro'

module Ramaze
  module View
    module Nagoro
      DEFAULT_PIPES = [
        :Element, :Morph, :Include, :RenderPartial, :Instruction, :Compile
      ]

      OPTIONS = { :pipes => DEFAULT_PIPES }

      def self.render(action, string = nil)
        string ||= action.view

        action.options[:pipes] ||= OPTIONS[:pipes]
        action.options[:filename] ||= action.view
        action.options[:binding] = action.binding
        action.options[:variables] = action.variables

        ::Nagoro.render(string.to_s, action.options)
      end
    end
  end
end

module Nagoro
  module Pipe
    # Pipe that transforms <render /> tags.
    #
    # the src parameter in the render tag will be used as first parameter to
    # render_partial, all other paramters are passed on as +options+.
    #
    # Example calling render_partial('/hello'):
    #   <render src="/hello" />
    #
    # Example calling render_partial('/hello', 'tail' => 'foo'):
    #   <render src="/hello" tail="foo" />
    #
    class RenderPartial < Base
      include Innate::Helper::Partial

      def tag_start(tag, attrs)
        if tag == 'render' and src = attrs.delete('src')
          append(render_partial(src, attrs))
        else
          super
        end
      end

      def tag_end(tag)
        super unless tag == 'render'
      end
    end
  end
end
