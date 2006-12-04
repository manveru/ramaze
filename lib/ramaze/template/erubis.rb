require 'erubis'

module Ramaze::Template
  class Erubis
    include Trinity

    trait :actionless => false

    class << self
      include Trinity

      def handle_request request, action, *params

        controller = self.new
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

        eruby = ::Erubis::Eruby.new(template)
        eruby.result(bound)

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

        exts = %w[rhtml rmze xhtml html]

        files = exts.map{|ext| "#{path}.#{ext}"}
        file = files.find{|file| File.file?(file)}
      end
    end
  end
end
