#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'nagoro'

module Ramaze
  module Template

    # Is responsible for compiling a template using the Ezamar templating engine.

    class Nagoro < Template

      ENGINES[self] = %w[ xhtml nag ]

      LISTENERS = [
        ::Nagoro::Listener::Element,
        ::Nagoro::Listener::Morpher,
        ::Nagoro::Listener::Include,
        ::Nagoro::Listener::Instruction,
        ::Nagoro::Listener::Compile
      ]

      class << self

        # Transforms an action into the XHTML code for parsing and returns
        # the result
        def transform action
          nagoro = wrap_compile(action)
          nagoro.eval(action.binding)
        end

        def file_or_result(action)
          result = render_method(action).to_s

          if file = action.template
            return File.new(file)
          end

          result
        end

        def wrap_compile(action, template = nil)
          template ||= file_or_result(action)
          caching_compile(action, template)
        end

        # Compile a template, applying all transformations from the pipeline
        # and returning an instance of ::Ezamar::Template

        def compile(action, template)
          render = ::Nagoro::Render.new(LISTENERS)
          render.filter(template)
          render
        end
      end
    end
  end
end
