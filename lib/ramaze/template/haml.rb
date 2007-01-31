#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template/haml/actionview_stub'
require 'haml/engine'

module Ramaze::Template
  class Haml < Template
    extend Ramaze::Helper

    trait :actionless => false
    trait :template_extensions => %w[haml]
    trait :haml_options => {
      :locals => {}
    }

    class << self
      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def handle_request action, *params
        controller = self.new
        controller.instance_variable_set('@action', action)
        result = controller.send(action, *params) if controller.respond_to?(action)

        file = find_template(action)

        template =
          if file
            File.read(file)
          elsif result.respond_to? :to_str
            result
          end

        return '' unless template

        bound = result.is_a?(Binding) ? result : controller.send(:send, :binding)

        controller.send(:transform, template, bound, file)
      rescue Object => ex
        puts ex
        Informer.error ex
        ''
      end
    end

    private

    # Transform any String via Erubis, takes an optional binding and filename

    def transform string, bound = binding, file = nil
      haml = ::Haml::Engine.new(string, ancestral_trait[:haml_options])
      haml.to_html(self)
    end
  end
end
