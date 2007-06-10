#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template/ezamar/engine'

module Ramaze
  module Template

    # Is responsible for compiling a template using the Ezamar templating engine.

    class Ezamar < Template

      ENGINES[self] = %w[ xhtml zmr ]

      TRANSFORM_PIPELINE = [ ::Ezamar::Element ]

      class << self

        def transform action
          ezamar =
            if Global.compile
              compiled_transform(action)
            else
              direct_transform(action)
            end

          ezamar.result(action.binding)
        end

        def compiled_transform(action)
          hash = action.relaxed_hash
          cache = Template::COMPILED
          if ezamar = cache[hash]
            ezamar
          else
            cache[hash] = direct_transform(action)
          end
        end

        def direct_transform(action)
          template = reaction_or_file(action).to_s
          compile(action, template)
        end

        def compile(action, template)
          file = (action.template || __FILE__)

          TRANSFORM_PIPELINE.each do |tp|
            template = tp.transform(template)
          end

          ::Ezamar::Template.new(template, :file => file)
        end
      end
    end
  end
end
