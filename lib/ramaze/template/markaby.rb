#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'markaby'

module Ramaze::Template
  class Markaby < Template

    Ramaze::Controller.register_engine self, %w[ mab ]

    class << self
      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def transform controller, options = {}
        action, parameter, file, bound = *super

        unless controller.private_methods.include?(action)
          mixed_in = controller.class.ancestors === MarkabyMixin
          controller.class.send(:include, MarkabyMixin) unless mixed_in

          reaction = controller.send(action, *parameter)

          mab = ::Markaby::Builder.new
          template =
            if file
              transform_file(controller, file)
            elsif reaction.respond_to? :to_str
              reaction
            end
        end

        return template if template
        raise Ramaze::Error::NoAction, "No Action found for `#{action}' on #{controller.class}"
      end

      def transform_file controller, file
        ivs = {}
        controller.instance_variables.each do |iv|
          ivs[iv.gsub('@', '').to_sym] = controller.instance_variable_get(iv)
        end
        controller.send(:mab, ivs) do
          instance_eval(File.read(file))
        end
      rescue Object => ex
        puts ex
        raise Ramaze::Error::Template, ex.message, ex.backtrace
      end
    end
  end

  module MarkabyMixin
    private

    # use this inside your controller to directly build Markaby
    # Refer to the Markaby-documentation and testsuite for more examples.
    # Usage:
    #   mab { h1 "Apples & Oranges"}                    #=> "<h1>Apples &amp; Oranges</h1>"
    #   mab { h1 'Apples', :class => 'fruits&floots' }  #=> "<h1 class=\"fruits&amp;floots\">Apples</h1>"

    def mab(*args, &block)
      builder = ::Markaby::Builder
      builder.extend(Ramaze::Helper)
      builder.send(:helper, :link)
      builder.new(*args, &block).to_s
    end
  end
end
