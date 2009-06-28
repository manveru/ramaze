module Ramaze
  class Bin
    class Version < Generic
      DESC = 'Show current ramaze version'
      HELP = <<-DOC
SYNOPSIS
  ramaze version

DESCRIPTION
  Show version number, copyright, and contact.

USAGE
  ramaze version
      DOC

      def parser(o, options)
      end

      def run(options)
        puts @bin.op.ver
        exit
      end
    end
  end
end
