require 'ezamar'

module Ramaze
  module View
    module Ezamar
      TRANSFORM_PIPELINE = [ ::Ezamar::Element ]

      def self.call(action, string)
        ezamar = View.compile(string){|s| compile(action, s) }
        html = ezamar.result(action.binding)
        return html, 'text/html'
      end

      def self.compile(action, template)
        file = action.view || __FILE__

        TRANSFORM_PIPELINE.each{|tp| template = tp.transform(template) }

        ::Ezamar::Template.new(template, :file => file)
      end
    end
  end
end
