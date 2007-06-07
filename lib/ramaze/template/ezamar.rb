#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template/ezamar/engine'

module Ramaze
  module Template

    # Is responsible for compiling a template using the Ezamar templating engine.

    class Ezamar < Template

      Ramaze::Controller.register_engine self, %w[ xhtml zmr ]

      TRANSFORM_PIPELINE = [ ::Ezamar::Element ]

      class << self

        def transform action
          template = reaction_or_file(action).to_s
          hash = action.hash

          ezamar =
            if Global.compile
              Template::COMPILED[hash] ||= compile(action, template)
            else
              compile(action, template)
            end

          ezamar.result(action.binding)
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
