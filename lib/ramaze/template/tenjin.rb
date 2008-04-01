require "tenjin"
require "tempfile"

class Tenjin::Context
  include Ramaze::Helper::Methods
  helper :link, :sendfile, :flash, :cgi
end

module Ramaze
  module Template

    # Is responsible for compiling a template using the Tenjin templating engine.
    # Can be found at: http://www.kuwata-lab.com/tenjin/

    class Tenjin < Template

      ENGINES[self] = %w[ rbhtml tenjin ]

      class << self
        # Transforms an action into the XHTML code for parsing and returns
        # the result
        def transform(action)
          tenjin = wrap_compile(action)
          context = action.instance.instance_variable_get("@context") || {}
          tenjin.render(context)
        end

        # Compile a template, applying all transformations from the pipeline
        # and returning an instance of ::Tenjin::Template
        def compile(action, template)
          tenjin = ::Tenjin::Template.new
          tenjin.convert(template)
          return tenjin
        end
      end
    end
  end
end
