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

      def code
        500
      end

      def out
        error = @error
        backtrace = @error.backtrace

        colors = []
        min = 160
        max = 255
        step = -((max - min) / backtrace.size).abs
        max.step(min, step) do |color|
          colors << color
        end

        backtrace.map! do |line|
          file, lineno, meth = line.scan(/(.*?):(\d+)(?::in `(.*?)')?/).first
          lines = __caller_lines__(file, lineno, 10)
          [ lines, lines.object_id.abs, file, lineno, meth ]
        end

        error_page(colors, error, *backtrace)
      end

      def error_page(colors, title, *backtrace)
        Gestalt.new{
          html do
          head do
            title{ title }
            style(:type => 'text/css') do
                %[
                <!--
                h1.main {
                  text-align: center;
                  }
                table.main {
                  width:      100%;
                  background: #000;
                  }
                table.main tr.head {
                  background: #fee;
                  width:      100%;
                  }
                table.main tr.source_container {
                  display:    none;
                  }
                tr.source_container div {
                  width:      100%;
                  overflow:   auto;
                  }
                tr.source_container div table {
                  background: #ddd;
                  width:      100%;
                  }
                tr.source_container div table tr {
                  text-align:center;
                  }
                tr.source_container div table tr.source {
                  text-align:left;
                  }
                -->
                 ]
            end
            # stupid firefox-hack... had to wait till the day something like that is
            # neccesary :P
            script(:type => 'text/javascript', :src => '/js/jquery.js'){}
          end
          body do
            h1(:class => :main){ title }
            table(:class => :main) do
              tr(:class => :head){ %w[File Line Method].each{|s| td{ s } } }

              backtrace.each do |lines, hash, file, lineno, meth|
                tr(:id => "line_#{hash}", :style => "background:rgb(#{colors.shift},70,60);") do
                  [file, lineno, meth].each{|s| td{ s } }
                end
                tr(:id => "source_#{hash}", :class => :source_container) do
                  td(:colspan => 3) do
                    div do
                      table do
                        tr{ td(:colspan => 2){ "vim #{file} +#{lineno}" } }

                        lines.each do |llineno, lcode, lcurrent|
                          style = lcurrent ? {:style => 'background:#faa;'} : {}
                          tr(style.merge(:class => :source)) do
                            td{ llineno.to_s }
                            td{ pre{ lcode } }
                          end # tr
                        end # lines.each
                      end # table
                    end # div
                    script(:type => 'text/javascript') do
                      %{ $("tr#line_#{hash}").click(function(){$("tr#source_#{hash}").toggle()}); }
                    end # script
                  end # td
                end # tr
              end # backtrace.each
            end # table
          end # body
          end # html
        }.to_s
      end
    end
  end
end
