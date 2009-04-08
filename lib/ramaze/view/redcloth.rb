#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'redcloth'

module Ramaze
  module View
    module RedCloth
      def self.call(action, string)
        restrictions = action.variables[:redcloth_options] || []
        rules        = action.variables[:redcloth_options] || []

        erubis, _ = Ramaze::View::Erubis.call(action, string)
        redcloth = ::RedCloth.new(erubis, restrictions)
        html = redcloth.to_html(*rules)

        return html, 'text/html'
      end
    end
  end
end
