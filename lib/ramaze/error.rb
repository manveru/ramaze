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
              title { title }
              # stupid firefox-hack... had to wait till the day something like that is
              # neccesary :P
              script(:type => 'text/javascript', :src => '/js/jquery.js'){}
            end
            body do
              h1(:style => 'font-size:100%;text-align:center;'){ title }
              table(:style => 'width:100%;background:#000;') do
                tr(:style => 'background:#fee;') do
                  %w[ File Line Method ].each do |s|
                    td{ s }
                  end
                end
                backtrace.each do |lines, hash, file, lineno, meth|
                  tr(:class => "line_#{hash}", :style => "background:rgb(#{colors.shift},70,60);") do
                    [ file, lineno, meth ].each{|s| td{ s }}
                  end
                  tr(:class => "code_#{hash}", :style => 'display:none') do
                    td(:colspan => 3) do
                      div(:style => 'overflow:hidden;width:100%;') do
                      table(:style => 'background:#ddd;width:100%') do
                        tr{ td(:colspan => 2, :style => 'text-align:center'){ "vim #{file} +#{lineno}" } }
                        lines.each do |llineno, lcode, lcurrent|
                          style = lcurrent ? {:style => 'background:#faa;'} : {}
                          tr(style) do
                            td{ llineno.to_s }
                            td{ pre{ lcode } }
                          end # tr
                        end # lines.each
                      end # table
                      end
                      script(:type => 'text/javascript') do
                        %{ $("tr.line_#{hash}").click(function(){$("tr.code_#{hash}").toggle()}); }
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
