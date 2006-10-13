module Ramaze
  module Template
    class Ramaze < Default
      def render action, controller
        debug :action, action, :controller, controller
        if controller.respond_to? action
          controller.send action
          template_file = "templates/#{action}.html"
          if File.exist?(template_file)
            template = File.read(template_file)
            controller.instance_eval do
              out instance_eval(%{"#{template}"})
            end
          end
          response = controller.send :response
          controller.send :response_reset
        else
          debug :error, NoActionError
          raise NoActionError, "No Action for #{self.class.name}.#{action}"
        end
        return response
      end
    end
  end
end
