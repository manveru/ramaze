require 'maruku'

module Innate
  module View
    module Maruku
      module_function

      def render(action, string = nil)
        string = File.read(action.view) if action.view
        ::Maruku.new(string).to_html
      end
    end
  end
end
