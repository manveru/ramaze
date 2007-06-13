#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'haml/engine'

module Ramaze
  module Template
    class Haml < Template

      # Custom HAML-options for your controller to be merged.

      trait :haml_options => {
        :locals => {}
      }

      ENGINES[self] = %w[ haml ]

      class << self

        # Transform any String via Haml, takes optionally an hash with the
        # haml_options that you can set also by
        #   trait :haml_options => {}
        # if you pass the options it will merge the trait with them. (your
        # options override the defaults from trait[:haml_options]

        def transform action
          haml = wrap_compile(action)
          haml.to_html(action.instance)
        end

        # Instantiates Haml::Engine with the template and haml_options from
        # the trait.

        def compile(action, template)
          ::Haml::Engine.new(template, ancestral_trait[:haml_options])
        end
      end
    end
  end
end
