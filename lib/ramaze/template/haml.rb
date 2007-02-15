#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template/haml/actionview_stub'
require 'haml/engine'

module Ramaze::Template
  class Haml < Template

    # Custom HAML-options for your controller to be merged.

    trait :haml_options => {
            :locals => {}
          }

    Ramaze::Controller.register_engine self, %w[ haml ]

    class << self

      # Transform any String via Haml, takes optionally an hash with the haml_options
      # that you can set also by
      #   trait :haml_options => {}
      # if you pass the options it will merge the trait with them. (your options
      # override the defaults from trait[:haml_options]

      def transform controller, options = {}
        action, parameter, file, bound = options.values_at(:action, :parameter, :file, :binding)

        reaction = controller.send(action, *parameter)
        template = reaction_or_file(reaction, file)

        return '' unless template

        haml = ::Haml::Engine.new(template, ancestral_trait[:haml_options])
        haml.to_html(controller)
      rescue Object => ex
        puts ex
        Informer.error ex
        ''
      end
    end
  end
end
