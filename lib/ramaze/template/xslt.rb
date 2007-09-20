require 'xml/libxml'
require 'xml/xslt'

module Ramaze

  # Use the Gestalt helper to put your controller result
  # into proper XML form
  #
  # TODO:
  # * Error handling
  # * Support for XML::XSLT::extFunction
  # * Non-fatal failure when missing Ruby-XSLT
  module Template
    class XSLT < Template
      ENGINES[self] = %w[ xsl ]

      class << self

        # Entry point for Action#render

        def transform action
          result, file = result_and_file(action)

          xslt = XML::XSLT.new
          xslt.xsl = action.template
          xslt.xml = result
          xslt.serve
        end

      end
    end
  end
end
