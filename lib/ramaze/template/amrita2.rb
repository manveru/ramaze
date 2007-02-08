#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'amrita2/template'

module Ramaze::Template
  class Amrita2 < Template

    # No actions on the controller are serached or called.
    trait :actionless => true

    # usual extensions for templates
    trait :template_extensions => %w[html amrita]

    class << self
      include Ramaze::Helper

      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def handle_request action, *params

        file = find_template(action)

        raise Ramaze::Error::Template, "No Template found for #{request.request_path}" unless file

        template = ::Amrita2::TemplateFile.new(file)
        out = ''
        controller = self.new
        controller.instance_variable_set('@params', params)
        template.expand(out, controller)
        out

      rescue Object => ex
        Informer.error ex
        raise Ramaze::Error::NoAction, "No Action found for #{request.request_path}"
      end
    end
  end
end
