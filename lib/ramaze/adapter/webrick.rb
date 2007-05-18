#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/adapter'

require 'rack/handler/webrick'

module WEBrick
  module HTTPServlet
    class ProcHandler
      alias do_PUT do_GET
      alias do_DELETE do_GET
    end
  end
end

module Ramaze
  module Adapter
    class WEBrick < Base
      class << self
        def run_server host, port, options = {}
          options = {
            :Port        => port,
            :BindAddress => host,
            :Logger      => Inform,
            :AccessLog   => [
              [Inform, ::WEBrick::AccessLog::COMMON_LOG_FORMAT],
              [Inform, ::WEBrick::AccessLog::REFERER_LOG_FORMAT]
            ]
          }.merge(options)


          server = ::WEBrick::HTTPServer.new(options)
          server.mount("/", ::Rack::Handler::WEBrick, self)
          thread = Thread.new(server) do |adapter|
            Thread.current[:adapter] = adapter
            adapter.start
          end
        end
      end
    end
  end
end
