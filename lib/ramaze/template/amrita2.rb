require 'amrita2/template'

module Ramaze::Template
  class Amrita2
    include Trinity

    trait :actionless => true

    class << self
      include Trinity

      def handle_request request, action, *params

        file = find_template(action)

        return '' unless file

        template = ::Amrita2::TemplateFile.new(file)
        out = ''
        template.expand(out, self.new)
        out

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

        exts = %w[html rhtml rmze xhtml]

        files = exts.map{|ext| "#{path}.#{ext}"}
        file = files.find{|file| File.file?(file)}
      end
    end
  end
end
