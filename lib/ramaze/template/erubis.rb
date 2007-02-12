#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'erubis'

module Ramaze::Template
  class Erubis < Template

    Controller.register_engine self, %w[ rhtml ]

    class << self
      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def transform controller, options = {}
        action, parameter, file, bound = options.values_at(:action, :parameter, :file, :binding)

        reaction = controller.send(action, *parameter)
        template = reaction_or_file(reaction, file)

        return '' unless template

        eruby = ::Erubis::Eruby.new(template)
        eruby.init_evaluator(:filename => file) if file
        eruby.result(bound)
      rescue Object => ex
        puts ex
        Informer.error ex
        ''
      end
    end
  end
end
