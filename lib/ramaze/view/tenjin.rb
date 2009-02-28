require 'tenjin'

module Ramaze
  module View
    module Tenjin
      def self.render(action, string)
        template = ::Tenjin::Template.new
        template.convert(string)

        action.copy_variables
        template.ramaze_render(action.binding)
      end
    end
  end
end

module Tenjin
  class Template
    # This method allows us to use tenjin with a binding, so helper methods are
    # available instead of only instance variables.
    # The big issue with this approach is that the original
    # Tenjin::ContextHelper is not available here. Patches welcome.
    def ramaze_render(binding)
      code = "_buf = #{init_buf_expr}; #{@script}; _buf.to_s"
      _buf = binding.eval(code, @filename || '(tenjin)')
    end
  end
end
