begin
  require 'rubygems'
  require 'mongrel'
rescue LoadError => ex
  puts ex
  puts "please install rubygems and mongrel"
end

require 'ramaze/tool/tidy'

module Ramaze::Adapter
  class Mongrel < ::Mongrel::HttpHandler
    def self.start host, port
      h = ::Mongrel::HttpServer.new host, port
      h.register "/", self.new
      h.run
    end

    def process(request, response)
      respond response, Dispatcher.handle(request, response)
    end

    def respond orig_response, response
      if response
        orig_response.start(response.code) do |head, out|
          set_head(head, response)
          set_out(out, response)
        end
      end
    end

    def set_out out, response
      if Global.tidy and (response.head['Content-Type'] == 'text/html' ? true : false)
        out << Tool::Tidy.tidy(response.out)
      else
        out << response.out
      end
    end

    def set_head head, response
      response.head.each do |key, val|
        head[key] = val
      end
    end
  end
end
