#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/adapter'

require 'webrick'

module WEBrick
  module HTTPServlet
    class ProcHandler
      alias do_PUT do_GET
      alias do_DELETE do_GET
    end
  end
end

module Ramaze::Adapter
  class Webrick < Base
    class << self
      def start host, ports
        ports.map{|port| run_server(host, port) }.first
      end

      def run_server host, port, options = {}
        options = {
          :Port => port,
          :BindAddress => host,
          :Logger => Informer,
          :AccessLog => [
            [Informer, WEBrick::AccessLog::COMMON_LOG_FORMAT],
            [Informer, WEBrick::AccessLog::REFERER_LOG_FORMAT]
          ]
        }.merge(options)

        Thread.new do
          Thread.current[:task] = :webrick
          Rack::Handler::WEBrick.run(self, options)
        end
      end
    end
  end
end
