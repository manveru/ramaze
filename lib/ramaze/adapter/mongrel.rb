#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/adapter'

require 'mongrel'

module Ramaze
  module Adapter
    class Mongrel < Base
      class << self
        def start host, ports
          ports.map do |port|
            Global.adapters << run_server(host, port)
          end
        end

        def run_server host, port
          options = { :Host => host, :Port => port }

          Thread.new do
            ::Rack::Handler::Mongrel.run(self, options) do |server|
              Thread.current[:adapter] = server
            end
          end
        end

        def call(env)
          new.call(env)
        end
      end
    end
  end
end
