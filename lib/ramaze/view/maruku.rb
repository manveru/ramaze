require 'maruku'

module Ramaze
  module View
    module Maruku
      def self.render(action, string)
        string = File.read(action.view) if action.view
        ::Maruku.new(string).to_html
      end
    end
  end
end
