require 'maruku'

module Ramaze
  module View
    module Maruku
      def self.call(action, string)
        string = File.read(action.view) if action.view
        html = ::Maruku.new(string).to_html

        return html, 'text/html'
      end
    end
  end
end
