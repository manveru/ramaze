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
          binding = action.binding
          lvars = eval('local_variables', binding)
          locals = lvars.inject({}){|h,v| h.update v => eval(v, binding)}
          haml.render(action.instance, @locals.merge(locals))
        end

        # Instantiates Haml::Engine with the template and haml_options trait from
        # the controller.

        def compile(action, template)
          haml_options = trait[:haml_options] || {} 
          @locals = haml_options.delete(:locals) || haml_options.delete('locals') || {} 
          ::Haml::Engine.new(template, action.controller.trait[:haml_options] || {})
        end
      end
    end
  end
end
