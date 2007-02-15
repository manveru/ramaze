#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template/ezamar/engine'

module Ramaze::Template

  # Is responsible for compiling a template using the Ezamar templating engine.

  class Ezamar < Template

    trait :transform_pipeline => [ Element, Morpher, self ]

    Ramaze::Controller.register_engine self, %w[ xhtml zmr ]

    class << self

      # Takes a controller and the options :action, :parameter, :file and :binding
      #
      # Uses Ezamar::Template to compile the template.

      def transform controller, options = {}
        unless options.is_a?(Binding) # little hack to allow inclusion into the pipeline
          action, parameter, file, bound = options.values_at(:action, :parameter, :file, :binding)

          real_transform controller, bound, file, action, *parameter
        else
          template, bound = controller, options
          ::Ezamar::Template.new(template).transform(bound)
        end
      rescue Object => ex
        Informer.error ex
        ''
      end

      # The actual transformation is done here.
      #
      # Getting the various possible template-files and the response from
      # the controller and then deciding based on them what goes into the
      # #pipeline

      def real_transform(controller, bound, file, action, *params)
        alternate     = file_template(params.last, controller) if params.size == 1 and action == 'index'
        file_template = file_template(file, controller)
        ctrl_template = render_action(controller, action, *params)

        pipeline(alternate || file_template || ctrl_template, bound)
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

        File.read(path)
      rescue
        nil
      end

      # Render an action, on a given controller with parameter

      def render_action(controller, action, *params)
        ctrl_template = controller.send(action, *params).to_s
      rescue => e
        Informer.error e unless e.message =~ /undefined method `#{Regexp.escape(action.to_s)}'/

        unless caller.select{|bt| bt[/`render_action'/]}.size > 3
          Dispatcher.respond_action([action, *params].join('/'))
          ctrl_template = Response.current.out
        end
      end

      # go through the pipeline and call #transform on every object found there,
      # passing the template at that point.
      # the order and contents of the pipeline are determined by an array
      # in trait[:template_pipeline]
      # the default being [Element, Morpher, self]
      #
      # TODO
      #   - put the pipeline into the Controller for use with all templates.

      def pipeline(template, bound = binding)
        transform_pipeline = ancestral_trait[:transform_pipeline]

        transform_pipeline.inject(template) do |memo, current|
          current.transform(memo, bound)
        end
      end
    end
  end
end
