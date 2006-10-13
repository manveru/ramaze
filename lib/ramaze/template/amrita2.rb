require 'amrita2/template'

module Ramaze
  module Template
    class Amrita2 < Default
      def render action, controller
        template_file = 'templates/' + controller.class.name.gsub('Controller', '').downcase + '.html'
        if File.exist?(template_file)
          template = Amrita2::TemplateFile.new(template_file)
          response = controller.send :response
          controller.send :response_reset
          template.expand(response.out, controller)
          return response
        end
      end
    end
  end
end
