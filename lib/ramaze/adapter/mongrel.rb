require 'rubygems'
require 'mongrel'

module Ramaze::Adapter
  class Mongrel < ::Mongrel::HttpHandler
    def self.start host, port
      h = ::Mongrel::HttpServer.new host, port
      h.register "/", self.new
      h.run
    end

    def process(request, response)
      respond response, Ramaze::Dispatcher.handle(request, response)
    end

    def respond orig_response, response
      if response
        orig_response.start(200) do |head, out|
          if response.respond_to? :head
            response.head.each do |key, val|
              head[key] = val if head.respond_to? :[]
            end
          end
          if response.respond_to? :out
            if Ramaze::Global.tidy and (response.head['Content-Type'] == 'text/html' ? true : false)
              out << tidy(response.out)
            else
              out << response.out
            end
          end
        end
      end
    end

    def tidy out
      require 'tidy'

      Tidy.path = `locate libtidy.so`.strip

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

      Tidy.open(:show_warnings => true) do |tidy|
        options.each do |key, value|
          tidy.options.send("#{key}=", value.to_s)
        end
        tidy.clean(html)
      end
    end
  end
end
