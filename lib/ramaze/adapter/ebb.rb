require 'ebb'

module Ramaze
  module Adapter
    class Ebb < Base
      class << self

        def run_server host, port
          ::Ebb.log = StringIO.new
          thread = Thread.new{ ::Ebb.start_server self, :port => port }
          thread[:adapter] = self
          thread
        end

        def shutdown
          ::Ebb.stop_server
        end

      end
    end
  end
end
