#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/adapter'

module Ramaze::Adapter
  class Cgi < Base
    class << self
      def start host, ports
        global = Ramaze::Global
        global.inform_to = :stderr if global.inform_to == $stdout
        run_server
      end

      def run_server
        Thread.new do
          Thread.current[:task] = :cgi
          Rack::Handler::CGI.run(self)
        end
      end
    end
  end
end
