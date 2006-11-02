module Ramaze::Template
  class Ramaze
    ann :actionless => false
    class << self
      def handle_request request, action, *params
        controller = self.new
        controller.__send__(action, *params)
      end
    end

    private

    include Trinity

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
