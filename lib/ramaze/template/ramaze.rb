module Ramaze::Template
  class Ramaze
    class << self
      def handle_request request, action, *params
        controller = self.new
        controller.instance_eval do
          out controller.__send__(action, *params).to_s
          template_file = "templates/#{action}.html"
          if File.exist?(template_file)
            template = File.read(template_file)
            out instance_eval(%{"#{template}"})
          end
        end

        return controller.out
      end
    end

    attr_accessor :out

    def out str = ''
      (@out ||= '') << str
    end
  end
end
