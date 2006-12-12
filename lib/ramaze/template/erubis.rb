#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'erubis'

module Ramaze::Template
  class Erubis
    extend Ramaze::Helper

    trait :actionless => false

    private

    helper :link, :redirect

    def transform string, bound = binding
      self.class.transform(string, bound)
    end

    class << self
      include Ramaze::Helper

      # initializes the handling of a request on the controller.
      # Creates a new instances of itself and sends the action and params.
      # Also tries to render the template.
      # In Theory you can use this standalone, this has not been tested though.

      def handle_request request, action, *params

        controller = self.new
        controller.instance_variable_set('@action', action)
        result = controller.send(action, *params) if controller.respond_to?(action)

        file = find_template(action)


        template =
          if file
            File.read(file)
          elsif result.respond_to? :to_str
            result
          end

        return '' unless template

        bound = result.is_a?(Binding) ? result : controller.send(:send, :binding)

        transform(template, bound)
      rescue Object => ex
        puts ex
        Logger.error ex
        ''
      end

      def transform string, bound = binding
        eruby = ::Erubis::Eruby.new(string)
        eruby.result(bound)
      end

      def find_template action
        path = 
          if template_root = trait[:template_root]
            template_root / action
          else
            Global.template_root / Global.mapping.invert[self] / action
          end
        path = File.expand_path(path)

        exts = %w[rhtml rmze xhtml html ephp ec ejava escheme eprl ejs].join(',')

        file = Dir["#{path}.{#{exts}}"].first
      end
    end
  end
end
