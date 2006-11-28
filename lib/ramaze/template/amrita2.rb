require 'amrita2/template'

module Ramaze::Template
  class Amrita2
    include Trinity

    trait :actionless => true

    class << self
      include Trinity

      def handle_request request, action, *params
        template_file = 
        if template_root = trait[:template_root]
          File.expand_path(File.join(template_root, action) << '.html')
        else
          File.expand_path((File.dirname($0) / 'template' / Global.mapping.invert[self] / action) << '.html')
        end

        template     = ::Amrita2::TemplateFile.new(template_file)
        out = ''
        template.expand(out, self.new)
        out
      rescue Object => ex
        puts ex
        Logger.error ex
        ''
      end
    end
  end
end
