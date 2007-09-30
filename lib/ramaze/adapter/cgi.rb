#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/adapter'

module Ramaze::Adapter

  # Our CGI adapter acts as wrapper for the Rack::Handler::CGI.
  class Cgi < Base
    class << self

      # start CGI in a new thread, host and port parameter are only taken
      # to make it compatible with other adapters but have no influence and
      # can be omitted
      def start host = nil, ports = nil
        Thread.new do
          Thread.current[:task] = :cgi
          Rack::Handler::CGI.run(self)
        end
      end
    end
  end
end
