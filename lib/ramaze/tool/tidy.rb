module Ramaze::Tool
  module Tidy
    def tidy out
      require 'rubygems'
      require 'tidy'

      ::Tidy.path = `locate libtidy.so`.strip

      html = out

      options = {
        :output_xml => true,
        :input_encoding => :utf8,
        :output_encoding => :utf8,
        :indent_spaces => 2,
        :indent => :auto,
        :markup => :yes,
        :wrap => 500
      }

      ::Tidy.open(:show_warnings => true) do |tidy|
        options.each do |key, value|
          tidy.options.send("#{key}=", value.to_s)
        end
        tidy.clean(html)
      end
    end
  end
end
