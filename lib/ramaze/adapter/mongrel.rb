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
      orig_response.start(200) do |head, out|
        response.head.each do |key, val|
          head[key] = val if head.respond_to? :[]
        end
        out << response.out
      end
    end
  end
end
