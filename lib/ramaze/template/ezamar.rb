#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template/ezamar/engine'

module Ramaze
  module Template

    # Is responsible for compiling a template using the Ezamar templating engine.

    class Ezamar < Template

      Ramaze::Controller.register_engine self, %w[ xhtml zmr ]

      trait :transform_pipeline => [ ::Ezamar::Element, ::Ezamar::Morpher, self ]
      trait :actionless => true

      class << self

        # Takes a controller and the options :action, :parameter, :file and :binding
        #
        # Uses Ezamar::Template to compile the template.

        def transform controller, options = {}
          if options.has_key?(:pipeline)
            template = ::Ezamar::Template.new(controller, options)
            template.transform(options[:binding])
          else
            action, parameter, file, bound = *super

            real_transform controller, bound, file, action, *parameter
          end
        end

        # The actual transformation is done here.
        #
        # Getting the various possible template-files and the response from
        # the controller and then deciding based on them what goes into the
        # #pipeline

        def real_transform(controller, bound, file, action, *params)
          alternate, path = safe{ file_template(params.last, controller) } if
            params.size == 1 and action == 'index'
          file_template, path = safe{ file_template(file, controller) }
          ctrl_template = safe{ render_action(controller, action, *params) }

          if chosen = alternate || file_template || ctrl_template
            pipeline(chosen, :binding => bound, :path => path)
          else
            raise_no_action(controller, action)
          end
        end

        # See if a string is an actual file.
        #
        # Answers with the contents and otherwise nil

        def file_template action_or_file, controller
          path =
            if File.file?(action_or_file)
              action_or_file
            else
              Controller.find_template(action_or_file, controller)
            end

          return File.read(path), path
        end

        # Render an action, on a given controller with parameter

        def render_action(controller, action, *params)
          return controller.send(action, *params).to_s
        rescue NoMethodError => ex
          ourself = /undefined method `#{action}' for #<TCErrorController:/
          if ex.message =~ ourself
            raise_no_action(controller, action)
          end
          nil
        end

        def raise_no_action(controller, action)
          raise Ramaze::Error::NoAction, "No Action found for `#{action}' on #{controller.class}"
        end

        # go through the pipeline and call #transform on every object found there,
        # passing the template at that point.
        # the order and contents of the pipeline are determined by an array
        # in trait[:template_pipeline]
        # the default being [Element, Morpher, self]
        #
        # TODO
        #   - put the pipeline into the Controller for use with all templates.

        def pipeline(template, options = {})
          transform_pipeline = ancestral_trait[:transform_pipeline]
          opts = options.reject{|k,v| [:template, :path, :binding].all?{|o| k != o}}
          opts[:pipeline] = :true

          transform_pipeline.inject(template) do |memo, current|
            current.transform(memo, opts)
          end
        end

        def safe
          yield
        rescue
          nil
        end
      end
    end
  end
end
