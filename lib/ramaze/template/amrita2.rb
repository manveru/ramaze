require 'amrita2/template'

module Ramaze::Template
  class Amrita2
    include Trinity

    ann :actionless => true

    class << self
      include Trinity

      def handle_request request, action, *params
        template_file = File.expand_path((File.dirname($0) / 'template' / Global.mapping.invert[self] / action) << '.html')
        template      = ::Amrita2::TemplateFile.new(template_file)
        out           = ''

        template.expand(out, self.new)
        out 
        p out
        p response
        response.out = out
        p response
      rescue Object => ex
        puts ex
        Logger.error ex
        ''
      end
    end
  end
end
