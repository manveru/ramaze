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

      def transform action
        template = reaction_or_file(action)

        eruby = ::Erubis::Eruby.new(template)
        eruby.init_evaluator(:filename => (action.template || __FILE__))
        eruby.result(action.binding)
      end
    end
  end
end
