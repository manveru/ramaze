begin
  require 'coderay'
rescue LoadError => ex
end

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
        STATUS_CODE[:internal_server_error]
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
          lines = __caller_lines__(file, lineno, 5)
          [ lines, lines.object_id.abs, file, lineno, meth ]
        end

        error_page(colors, error, *backtrace)
      end

      # excuse the complexity...
      # this basically shows the error-page, but i will have to split this up a lot
      # more so it can be reused in other parts...
      # the CSS should be defined somewhere else, also the inspects are
      # quite repetive
      # also this method offers highlighting for the sourcecode-chunks from the
      # traceback, just install rubygems/coderay :)
      # oh, and yeah, no example - don't call this yourself

      def error_page(colors, title, *backtrace)
        show_hide_block = lambda do |title, content|
          hash = [title, content].object_id.abs
          Gestalt.new{
            div(:class => :additional) do
              h3(:id => "show_#{hash}"){title}
              pre(:style => 'display:none', :id => "is_#{hash}"){content}
              script(:type => 'text/javascript') do
                %{ $("h3#show_#{hash}").click(function(){$("pre#is_#{hash}").toggle()}); }
              end
            end
            }.to_s
        end

        coderay = Object.constants.include?('CodeRay')

        Gestalt.new{
          html do
            head do
              title{ title }
              link :rel => "stylesheet", :href => "css/coderay.css"
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
                  div.source {
                    background: #fff;
                    }
                  -->
                   ]
              end
              # stupid firefox-hack... had to wait till the day something like that is
              # neccesary :P
              script(:type => 'text/javascript', :src => '/js/jquery.js'){}
            end
            body do
              span(:style => 'float:left') do
                img :src => '/ramaze.png'
              end
              h1(:class => :main){ title }
              table(:class => :main) do
                tr(:class => :head){ %w[File Line Method].each{|s| td{ s } } }

                backtrace.each do |lines, hash, file, lineno, meth|
                  tr(:id => "line_#{hash}", :style => "background:rgb(#{colors.shift},70,60);") do
                    [file, lineno, meth].each{|s| td{ s } }
                  end
                  tr(:id => "source_#{hash}", :style => 'display:none') do
                    td(:colspan => 3) do
                      div(:class => :source) do
                        table do
                          tr{ td(:colspan => 2){ "vim #{file} +#{lineno}" } }

                          lines.each do |llineno, lcode, lcurrent|
                            style = lcurrent ? {:style => 'background:#faa;'} : {}
                            tr(style.merge(:class => :source)) do
                              td{ llineno.to_s }
                              td do
                                coderay ? CodeRay.scan(lcode, :ruby).html : pre{ lcode }
                              end # td
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
              show_hide_block['Session',  Thread.current[:session].pretty_inspect  ] +
              show_hide_block['Request',  Thread.current[:request].pretty_inspect  ] +
              show_hide_block['Response', Thread.current[:response].pretty_inspect ] +
              show_hide_block['Global',   Global.pretty_inspect                    ]
            end # body
          end # html
        }.to_s
      end

      def show_hide_block(title, content)
        # get a unique id (more or less)
      end
    end
  end
end
