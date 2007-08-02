#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # Subclassing Rack::Response for our own purposes.
  class Response < ::Rack::Response
    # build a response, default values are from the current response.

    def build body = body, status = status, head = header
      Dispatcher.set_cookie if Global.sessions

      head.each do |key, value|
        self[key] = value
      end

      self.body, self.status = body, status
      self
    end

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
