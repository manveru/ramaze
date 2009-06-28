module Ramaze
  class Bin
    class Console < Generic
      DESC = 'Starts an irb console with start.rb or app.rb'
      HELP = <<-DOC
SYNOPSIS
ramaze console [options]

DESCRIPTION
  Starts an irb console with app.rb (and irb completion) loaded. This command
  ignores any other options, ARGV is passed on to IRB.

USAGE
  ramaze console
      DOC

      def run(options)
        console
      rescue Exception => ex
        puts ex
      ensure
        exit
      end

      private

      def console
        require 'irb'
        require 'irb/completion'

        require_ramaze

        Ramaze.options.started = true
        Ramaze.instance_variable_set(:@reloader, Rack::Reloader.new(lambda{|env|}, 0))

        def Ramaze.reload!
          @reloader.call({})
        end

        begin
          require File.expand_path("start")
        rescue LoadError
          require File.expand_path('app')
        end

        Ramaze.reload! # the pristine state
        puts "To reload your source files, call Ramaze.reload!"

        ARGV.shift
        IRB.start

        puts "Ramazement has ended, go in peace."
      end
    end
  end
end
