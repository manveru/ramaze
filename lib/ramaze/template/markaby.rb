#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'markaby'

module Ramaze::Template
  class Markaby < Template
    extend Ramaze::Helper

    # Actions consist of both templates and methods on the controller.
    trait :actionless => false

    # Usual extensions for templates.
    trait :template_extensions => %w[mab]

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

    class << self

      # Takes the action and parameter
      # creates a new instance of itself, sets the @action instance-variable
      # to the action just called, the sends the action and parameter further
      # on to the instance (if the instance responds to the action)
      #
      # uses the #find_template method for the action to locate the template
      # and uses the response from the template instead in case there is no
      # template (and the response from the template responds to to_str)

      def handle_request action, *params
        controller = self.new
        controller.instance_variable_set('@action', action)

        result = controller.send(action, *params) if controller.respond_to?(action)
        file = find_template(action)

        mab = ::Markaby::Builder.new

        template =
          if file
            ivs = {}
            controller.instance_variables.each do |iv|
              ivs[iv.gsub('@', '').to_sym] = controller.instance_variable_get(iv)
            end
            controller.send(:mab, ivs) do
              instance_eval(File.read(file))
            end
          elsif result.respond_to? :to_str
            result
          end

        template ? template : ''
      end
    end
  end
end
