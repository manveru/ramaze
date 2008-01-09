#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'haml/engine'

module Ramaze
  module Template

    # Is responsible for compiling a template using the Haml templating engine.
    # Can be found at: http://haml.hamptoncatlin.com/

    class Haml < Template

      ENGINES[self] = %w[ haml ]

      class << self

        # Transform via Haml templating engine

        def transform action
          haml = wrap_compile(action)
          haml.to_html(action.instance)
        end

        # Instantiates Haml::Engine with the template and haml_options trait from
        # the controller.

        def compile(action, template)
          ::Haml::Engine.new(template, action.controller.trait[:haml_options] || {})
        end
      end
    end
  end
end
