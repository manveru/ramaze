require 'ramaze/adapter'

module Ramaze::Adapter

  # Our Lsws adapter acts as wrapper for the Rack::Handler::LSWS.
  class Lsws < Base
    class << self

      # start Lsws in a new thread, host and port parameter are only taken
      # to make it compatible with other adapters but have no influence and
      # can be omitted
      def run_server host = nil, ports = nil
        Thread.new do
          Rack::Handler::LSWS.run(self)
        end
      end
    end
  end
end
