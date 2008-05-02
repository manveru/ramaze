#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Response < Rack::Response
    class << self
      # Alias for Current::response
      def current() Current.response end
    end

    def initialize(body = [], status = 200, header = {}, &block)
      header['Content-Type'] ||= Global.content_type
      super
    end

    # Build/replace this responses data
    def build(body = body, status = status, header = header)
      header.each do |key, value|
        self[key] = value
      end

      self.body, self.status = body, status
      self
    end
  end
end
