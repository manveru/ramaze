#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Tool

    # This is a simple tool to tidy up your html-output
    # in general this is just used by setting Global.tidy = true

    module Tidy

      # set this to define a custom path to your tidy.so
      trait[:path] ||= `locate libtidy.so`.strip

      # dirty html in, tidy html out
      # To activate Tidy for everything outgoing (given that it is of
      # Content-Type text/html) set
      #   Global.tidy = true
      # there is almost no speed-tradeoff but makes debugging a much
      # nicer experience ;)
      #
      # Example:
      #
      #  include Ramaze::Tool::Tidy
      #  puts tidy('<html></html>')
      #
      #  # results in something like:
      #
      #   <html>
      #     <head>
      #       <meta name="generator" content="HTML Tidy for Linux/x86 (vers 1 September 2005), see www.w3.org" />
      #       <title></title>
      #     </head>
      #     <body></body>
      #   </html>

      def self.tidy html, options = {}
        require 'tidy'

        ::Tidy.path = trait[:path]

        defaults = {
          :output_xml => true,
          :input_encoding => :utf8,
          :output_encoding => :utf8,
          :indent_spaces => 2,
          :indent => :auto,
          :markup => :yes,
          :wrap => 500
        }

        ::Tidy.open(:show_warnings => true) do |tidy|
          defaults.merge(options).each do |key, value|
            tidy.options.send("#{key}=", value.to_s)
          end
          tidy.clean(html)
        end
      rescue LoadError => ex
        puts ex
        puts "cannot load 'tidy', please `gem install tidy`"
        puts "you can find it at http://tidy.rubyforge.org/"
      end

      # calls self#tidy

      def tidy html, options = {}
        Ramaze::Tool::Tidy.tidy(html, options)
      end
    end
  end
end
