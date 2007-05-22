#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template/ezamar/engine'

module Ramaze
  module Template

    # Is responsible for compiling a template using the Ezamar templating engine.

    class Ezamar < Template

      Ramaze::Controller.register_engine self, %w[ xhtml zmr ]

      trait :transform_pipeline => [
        ::Ezamar::Element, ::Ezamar::Template
      ]

      trait :actionless => true

      class << self

        # Takes a controller and the options :action, :parameter, :file and :binding
        #
        # Uses Ezamar::Template to compile the template.

        def transform action
          ctrl_template = render_method(action)

          template =
            if file = action.template
              File.read(file)
            else
              ctrl_template.to_s
            end
          file = (action.template || __FILE__)
          pipeline(template.to_s, action.binding, file)
        end

        def render_method(action)
          return unless method = action.method
          action.controller.__send__(method, *action.params)
        end

        # go through the pipeline and call #transform on every object found there,
        # passing the template at that point.
        # the order and contents of the pipeline are determined by an array
        # in trait[:template_pipeline]
        # the default being [Element, Morpher, self]
        #
        # TODO
        #   - put the pipeline into the Controller for use with all templates.

        def pipeline(template, binding, file)
          class_trait[:transform_pipeline].each do |klass|
            template = klass.transform(template, binding, file)
          end

          template
        end
      end
    end
  end
end
