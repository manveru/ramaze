require 'less'

module Ramaze
  module View
    module Less
      def self.call(action, string)
        less = View.compile(string){|s| ::Less::Engine.new(s) }
        return less.to_css, 'text/css'
      end
    end
  end
end
