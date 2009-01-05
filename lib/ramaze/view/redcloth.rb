require 'redcloth'

module Ramaze
  module View
    module RedCloth
      extend Ramaze::View.get(:Erubis)

      def self.render(action, string)
        restrictions = action.variables[:redcloth_options] || []
        rules        = action.variables[:redcloth_options] || []

        # Erubis -> RedCloth -> HTML
        redcloth = ::RedCloth.new(super, restrictions)
        redcloth.to_html(*rules)
      end
    end
  end
end
