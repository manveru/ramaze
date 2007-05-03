#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'liquid'

module Ramaze
  module Template
    class Liquid < Template
      Controller.register_engine self, %w[ liquid ]

      class << self

        # initializes the handling of a request on the controller.
        # Creates a new instances of itself and sends the action and params.
        # Also tries to render the template.
        # In Theory you can use this standalone, this has not been tested though.

        def transform controller, options = {}
          action, parameter, file, bound = *super

          reaction = controller.send(action, *parameter)
          template = reaction_or_file(reaction, file)

          return '' unless template

          hash     = controller.instance_variable_get("@hash") || {}
          template = ::Liquid::Template.parse(template)
          options  = controller.ancestral_trait[:liquid_options]

          template.render(hash, options)
        end
      end
    end
  end
end
