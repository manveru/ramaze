require 'redcloth'

module Ramaze
  module View
    module RedCloth
      def self.render(action, string = nil)
        restrictions = action.variables[:redcloth_options] || []
        rules        = action.variables[:redcloth_options] || []

        erubis = Ramaze::View::Erubis.render(action, string)
        redcloth = ::RedCloth.new(erubis, restrictions)
        redcloth.to_html(*rules)
      end
    end
  end
end
