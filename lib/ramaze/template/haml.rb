#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

if not ENV['FORCE_HAML'] and defined?(gem)
  begin
    gem 'haml', '=1.5.2'
  rescue Gem::Exception => ex
    match_error = /can't activate haml \(= 1\.5\.2\), already activated haml-(.*?)\]/
    version = ex.message[match_error, 1]
    if version == "1.7.0"
      begin
        require 'activesupport'
      rescue LoadError => ex
        puts ex,
        "You seem to use a haml version incompatible with Ramaze.",
        "Either make sure the version 1.5.2 of haml is installed,",
        "or additionally install activesupport to use this version.",
        "If you think this check is wrong, set FORCE_HAML=1 before or on",
        "starting Ramaze."
        exit 1
      end
    end
  end
end

require 'haml/engine'

module Ramaze
  module Template

    # Is responsible for compiling a template using the Haml templating engine.
    # Can be found at: http://haml.hamptoncatlin.com/

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
