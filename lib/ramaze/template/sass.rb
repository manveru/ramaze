#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'sass/engine'

module Ramaze
  module Template

    # Is responsible for compiling a template using the Sass CSS templating engine.
    # Can be found at: http://haml.hamptoncatlin.com/

    class Sass < Template

      # Custom SASS-options for your controller to be merged.

      trait :sass_options => {
        :locals => {}
      }

      ENGINES[self] = %w[ sass ]

      class << self

        # Transform any String via Sass, takes optionally an hash with the
        # sass_options that you can set also by
        #   trait :sass_options => {}
        # if you pass the options it will merge the trait with them. (your
        # options override the defaults from trait[:sass_options]

        def transform action
          Response.current['Content-Type'] = "text/css"
          sass = wrap_compile(action)
          sass.to_css()
        end

        # Instantiates Sass::Engine with the template and sass_options from
        # the trait.

        def compile(action, template)
          ::Sass::Engine.new(template, ancestral_trait[:sass_options])
        end
      end
    end
  end
end
