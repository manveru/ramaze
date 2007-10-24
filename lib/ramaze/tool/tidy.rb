#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Tool

    # This is a simple tool to tidy up your html-output
    #
    # Usage:
    #   Ramaze::Dispatcher::Action::FILTER << Ramaze::Tool::Tidy

    module Tidy

      trait[:enable] ||= false

      # set this to define a custom path to your tidy.so
      trait[:paths] ||= %w[
        /usr/lib/libtidy.so
        /usr/local/lib/libtidy.so
        /usr/lib/libtidy.dylib
      ]

      trait[:path] ||= nil

      trait[:options] ||= {
        :output_xml => true,
        :input_encoding => :utf8,
        :output_encoding => :utf8,
        :indent_spaces => 2,
        :indent => :auto,
        :markup => :yes,
        :wrap => 500
      }

      class << self

        # dirty html in, tidy html out
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

        def tidy html, options = {}
          require 'tidy'

          unless found = trait[:path]
            found = trait[:paths].find do |path|
              File.exists?(path)
            end
            trait[:path] = found
          end

          path = trait[:path]

          unless path
            Inform.error("Could not find `libtidy.so' in #{trait[:paths].inspect}")
            return html
          end

          ::Tidy.path = path

          ::Tidy.open(:show_warnings => true) do |tidy|
            opts = trait[:options].merge(options)
            opts.each do |key, value|
              tidy.options.send("#{key}=", value.to_s)
            end
            tidy.clean(html)
          end
        rescue LoadError => ex
          puts ex
          puts "cannot load 'tidy', please `gem install tidy`"
          puts "you can find it at http://tidy.rubyforge.org/"
        end

        # Enables being plugged into Dispatcher::Action::FILTER

        def call(response, options = {})
          return response unless trait[:enable]
          response.body = tidy(response.body, options)
          response
        end
      end

      # calls Tidy::tidy

      def tidy html, options = {}
        Ramaze::Tool::Tidy.tidy(html, options)
      end
    end
  end
end
