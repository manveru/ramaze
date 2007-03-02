#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'erubis'

module Ramaze::Template

  # Is responsible for compiling a template using the Erubis templating engine.

  class Erubis < Template

    Ramaze::Controller.register_engine self, %w[ rhtml ]

    class << self

      # Takes a controller and the options :action, :parameter, :file and :binding
      #
      # Builds a template out of the method on the controller and the
      # template-file.

      def transform controller, options = {}
        action, parameter, file, bound = *super

        reaction = controller.send(action, *parameter)
        template = reaction_or_file(reaction, file)

        return '' unless template

        eruby = ::Erubis::Eruby.new(template)
        eruby.init_evaluator(:filename => file) if file
        eruby.result(bound)
      end
    end
  end
end
