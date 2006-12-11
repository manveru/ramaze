#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'erubis'

module Ramaze::Template
  class Markaby
    extend Ramaze::Helper

    trait :actionless => false

    # use this inside your controller to directly build Markaby
    # Refer to the Markaby-documentation and testsuite for more examples.
    # Usage:
    #   mab { h1 "Apples & Oranges"}                    #=> "<h1>Apples &amp; Oranges</h1>"
    #   mab { h1 'Apples', :class => 'fruits&floots' }  #=> "<h1 class=\"fruits&amp;floots\">Apples</h1>"
    def mab(*args, &block)
      ::Markaby::Builder.new(*args, &block).to_s
    end

    class << self
      include Ramaze::Helper

      def handle_request request, action, *params
        require 'markaby'

        controller = self.new
        result = controller.send(action, *params) if controller.respond_to?(action)
        file = find_template(action)

        mab = ::Markaby::Builder.new

        p :file => file, :result => result

        template =
          if file
            ivs =
              controller.instance_variables.map do |iv|

            mab(.instance_eval(File.read(file))
          elsif result.respond_to? :to_str
            result
          end

        p template

        template ? template : ''

      rescue Object => ex
        puts ex
        Logger.error ex
        ''
      end

      def find_template action
        path = 
          if template_root = trait[:template_root]
            template_root / action
          else
            Global.template_root / Global.mapping.invert[self] / action
          end
        path = File.expand_path(File.dirname($0) / path)

        exts = %w[mab rmze]

        files = exts.map{|ext| "#{path}.#{ext}"}
        file = files.find{|file| File.file?(file)}
      end
    end
  end
end
