module Ramaze::Template
  class Ramaze
    class << self
      def handle_request request, action, *params
        out = ''

        controller = self.new(request)
        out << controller.send(action, *params)
        template_file = "templates/#{action}.html"
        if File.exist?(template_file)
          template = File.read(template_file)
          controller.instance_eval do
            out instance_eval(%{"#{template}"})
          end
        end

        return out
      end
    end

    def out str = ''
      @out << str
    end
  end
end
