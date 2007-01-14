#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

begin
  require 'coderay'
rescue LoadError => ex
end

module Ramaze
  module Error
    class NoAction < StandardError; end
    class NoController < StandardError; end
    class WrongParameterCount < StandardError; end
    class Template < StandardError; end

    class Response
      def initialize error
        @error = error
      end

      def head
        { 'Content-Type' => 'text/html' }
      end

      def content_type
        head['Content-Type']
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

      def error_page colors, title, *backtrace
        @backtrace = backtrace
        @colors = colors
        @title = title
        @coderay = Object.constants.include?('CodeRay')

        template = 
          <<-HEREDOC
<html>
  <head>
    <title><%= @title %></title>
    <link rel="stylesheet" href="/css/coderay.css" />
    <style type="text/css">
      <!--
      h1.main {
        text-align: center;
        }
      table.main {
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
    </style>
    <script type="text/javascript" src="/js/jquery.js"></script>
  </head>
  <body>
    <span style="float:left;">
      <img src="/ramaze.png" />
    </span>
    <h1><%= @title %></h1>
    <table class="main">
      <tr class="head">
        <td>File</td><td>Line</td><td>Method</td>
      </tr>
      <?r @backtrace.each do |lines, hash, file, lineno, meth| ?>
        <tr id="line_<%= hash %>" style="background:rgb(<%= @colors.shift %>,70,60);">
          <td><%= file %></td><td><%= lineno %></td><td><%= meth %></td>
        </tr>
        <tr id="source_<%= hash %>" style="display:none;">
          <td colspan="3">
            <div class="source">
              <table>
                <tr>
                  <td colspan="2">vim <%= file %> +<%= lineno %></td>
                </tr>
                <?r lines.each do |llineno, lcode, lcurrent| ?>
                  <tr class="source"<%=  'style="background:#faa;"' if lcurrent %>>
                    <td><%= llineno %></td>
                    <td>
                      <%= @coderay ? CodeRay.scan(lcode, :ruby).html : "<pre>\#{lcode}</pre>" %>
                    </td>
                  </tr>
                <?r end ?>
              </table>
            </div>
            <script type="text/javascript">
              $("tr#line_<%= hash %>").click(function(){$("tr#source_<%= hash %>").toggle()});
            </script>
          </td>
        </tr>
      <?r end ?>
    </table>
    <?r
      {
        'Session'   => Thread.current[:session],
        'Request'   => Thread.current[:request],
        'Response'  => Thread.current[:response],
        'Global'    => Global,
      }.each do |title, content|
        hash = [title, content].object_id.abs
      ?>
      <div class="additional">
        <h3 id="show_<%= hash %>"><%= title %></h3>
        <pre style="display:none" id="is_<%= hash %>"><%= content.pretty_inspect %></pre>
        <script type="text/javascript">
          $("h3#show_<%= hash %>").click(function(){$("pre#is_<%= hash %>").toggle()});
        </script>
      </div>
    <?r end ?>
  </body>
</html>
        HEREDOC

        Ramaze::Template::Ramaze.new.send(:transform, template, binding)
      end
    end
  end
end
