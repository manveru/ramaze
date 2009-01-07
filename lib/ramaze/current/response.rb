#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Response < Rack::Response
    # Alias for Current.response
    def self.current; Current.response; end

    def initialize(body = [], status = 200, header = {}, &block)
      modified_header = Ramaze.options.header.merge(header)
      header.merge!(modified_header)
      super
    end

    # Build/replace this responses data
    def build(new_body = nil, new_status = nil, new_header = nil)
      self.header.merge!(new_header) if new_header

      self.body   = new_body if new_body
      self.status = new_status if new_status
    end

    def body=(obj)
      if obj.respond_to?(:stat)
        @length = obj.stat.size
        @body = obj
      elsif obj.respond_to?(:size)
        @body = []
        @length = 0
        write(obj)
      else
        raise(ArgumentError, "Invalid body: %p" % obj)
      end
    end
  end
end
