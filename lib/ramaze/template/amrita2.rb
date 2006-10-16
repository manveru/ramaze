require 'amrita2/template'

module Ramaze::Template
  class Amrita2
    class << self
      def handle_request request, action, *params
        p [self, :handle_request, request, action, params]
        @template_root ||= 'template'
        template = @template_root / Global.mapping.invert[self] / action
        template << '.html'
        out = ''
        if File.exist?(template)
          template = ::Amrita2::TemplateFile.new(template)
          controller = self.new
          template.expand(out, controller)
        end
      end
    end

=begin
    private

    def initialize request
      @request = request
    end

    def request request = @request
      @request = request
    end
=end
  end
end
