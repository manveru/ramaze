#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Response < ::Rack::Response
    class << self

      # get the current response out of Thread.current[:response]
      #
      # You can call this from everywhere with Ramaze::Response.current

      def current
        Thread.current[:response]
      end
    end
  end
end
