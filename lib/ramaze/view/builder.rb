require 'builder'

module Ramaze
  module View
    module Builder
      module_function

      def self.render(action, string = nil)
        template = compile(string)
        action.instance.instance_eval(template, action.view || __FILE__)
      end

      def self.compile(string)
<<COMPILE
x = ::Builder::XmlMarkup.new(:indent => 2)
#{string}
x.target!
COMPILE
      end
    end
  end
end
