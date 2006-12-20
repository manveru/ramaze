#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'markaby'

module Ramaze::Template
  class Markaby < Template
    extend Ramaze::Helper

    trait :actionless => false
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
