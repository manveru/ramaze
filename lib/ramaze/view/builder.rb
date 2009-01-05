require 'builder'

module Innate
  module View
    module Builder
      module_function

      def render(action, string = nil)
        string = File.read(action.view) if action.view
        template = compile(string)
        action.instance.instance_eval(template, action.view || __FILE__)
      end

      def compile(string)
<<COMPILE
x = ::Builder::XmlMarkup.new(:indent => 2)
#{string}
x.target!
COMPILE
      end
    end
  end
end
