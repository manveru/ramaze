require 'ebb'

module Ramaze
  module Adapter
    class Ebb < Base
      class << self

        # start server on given host and port.
        def run_server host, port
          server = ::Ebb::Server.new(self, :port => port)

          thread = Thread.new{ server.start }
          thread[:adapter] = server
          thread
        end
      end
    end
  end

  class Response
    def finish(&block)
      @block = block

      if [201, 204, 304].include?(status.to_i)
        header.delete "Content-Type"
        [status.to_i, header.to_hash, '']
      else
        [status.to_i, header.to_hash, [body].flatten.join]
      end
    end
  end
end
