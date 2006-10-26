module Ramaze::Template
  class Ramaze
    class << self
      def handle_request request, action, *params
        controller = self.new
        controller.__send__(action, *params)
      end
    end

    private

    def render template
      file = File.join(Global.template_root, Global.mapping.invert[self.class], "#{template}.rmze")

      if File.exist?(file)
        transform(file, ivs)
      else
        ''
      end
    end

    def redirect target
      response.head['Location'] = target
      response.code = 303
      %{Please follow <a href="#{target}">#{target}</a>!}
    end
  end
end

=begin

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

      def transform template = '', ivs = ivs
        self.new do
          ivs.each{ |k, v| __instance_variable_set__(k, v) }
          __instance_eval__(template)
        end
      end
    end

    private

    def render template
      template_transform(File.read("template/#{template}.rmze"), ivs)
    end

    def redirect target
      Gestalt.new{html{body{a(:href => "/#{target}"){target.to_s}}}}
    end

    def out str = ''
      (@out ||= '') << str
    end
  end
end
=end
