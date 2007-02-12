#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'amrita2/template'

module Ramaze::Template
  class Amrita2 < Template

    Controller.register_engine self, %w[ amrita ]

    class << self
      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def transform controller, options = {}
        action, parameter, file, bound = options.values_at(:action, :parameter, :file, :binding)

        raise Ramaze::Error::Template, "No Template found for #{Request.current.request_path}" unless file

        template = ::Amrita2::TemplateFile.new(file)
        out = ''
        controller.instance_variable_set('@params', parameter)
        template.expand(out, controller)
        out
      rescue Object => ex
        puts ex
        Informer.error ex
        ''
      end
    end
  end
end
