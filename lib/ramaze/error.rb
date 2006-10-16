module Ramaze
  module Error
    class NoAction < StandardError; end
    class NoController < StandardError; end
    class WrongParameterCount < StandardError; end

    class Response
      def initialize error
        @error = error
      end

      def head
        { 'Content-Type' => 'text/html' }
      end

      def out
        g = Gestalt.new
        backtrace = @error.backtrace
        colors = []
        255.step(50, -(205 / backtrace.size)) do |color|
          colors << color
        end

        g.h1{ @error.message.to_s }
        g.table(:style => 'width:100%'){
          g.tr{
            g.td{'File'}
            g.td{'Line'}
            g.td{'Method'}
          }

          backtrace.map do |line|
            g.tr(:style => "background:RGB(#{colors.shift},30,20)"){
              if (scan = line.scan(/(.*?):(\d+):in `(.*?)'/)).empty?
                scan = line.scan(/(.*?):(\d+)/)
              end
              scan.first.each do |s|
                g.td{s}
              end
            }
          end
        }
        g.to_s
      end
    end
  end
end
