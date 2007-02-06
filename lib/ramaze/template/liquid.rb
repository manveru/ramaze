#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'liquid'

module Ramaze::Template
  class Liquid < Template
    extend Ramaze::Helper

    # Actions consist of both templates and methods on the controller.
    trait :actionless => false

    # Usual extensions for templates.
    trait :template_extensions => %w[liquid]

    # Custom options for Liquid to be merged for your controller.
    trait :liquid_options => {}

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

        p file

        template =
          if file
            File.read(file)
          elsif result.respond_to? :to_str
            result
          end

        return '' unless template

        controller.send(:transform, template)
      rescue Object => ex
        puts ex
        Informer.error ex
        ''
      end
    end

    private

    # Transform any String via Liquid, takes an optional hash for the parameters
    #   transform("hi {{name}}", 'name' => 'tobi') # => "hi tobi"
    #
    # Usually you will just do this in the controller:
    #
    #   class MainController < Template::Liquid
    #     def index
    #       @hash = {'name' => 'tobi'}
    #     end
    #   end
    #
    # And the templating will use @hash by default, setting it to {} if it is
    # not set yet.

    def transform string, hash = {}, options = {}
      @hash ||= hash
      template = ::Liquid::Template.parse(string)
      options = ancestral_trait[:liquid_options].merge(options)
      template.render(@hash, options)
    end
  end
end
