#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'cgi'
require 'tmpdir'
require 'digest/md5'
require 'rack'
require 'rack/request'

module Ramaze

  # The purpose of this class is to act as a simple wrapper for Rack::Request
  # and provide some convinient methods for our own use.

  class Request < ::Rack::Request
    class << self

      # get the current request out of Thread.current[:request]
      #
      # You can call this from everywhere with Ramaze::Request.current

      def current
        Thread.current[:request]
      end
    end

    # you can access the original @request via this method_missing,
    # first it tries to match your method with any of the HTTP parameters
    # then, in case that fails, it will relay to @request

    def method_missing meth, *args, &block
      key = meth.to_s.upcase
      return env[key] if env.has_key?(key)
      super
    end

    unless defined?(rack_params)
      alias rack_params params

      # Wrapping Request#params to support a one-level hash notation.
      # It doesn't support anything really fancy, so be conservative in its use.
      #
      # Example Usage:
      #
      #  # Template:
      #
      #  <form action="/paste">
      #    <input type="text" name="paste[name]" />
      #    <input type="text" name="paste[syntax]" />
      #    <input type="submit" />
      #  </form>
      #
      #  # In your Controller:
      #
      #  def paste
      #    name, syntax = request.params['paste'].values_at('name', 'syntax')
      #    paste = Paste.create_with(:name => name, :syntax => syntax)
      #    redirect '/'
      #  end
      #
      #  # Or, easier:
      #
      #  def paste
      #    paste = Paste.create_with(request.params)
      #    redirect '/'
      #  end

      def params
        ps = rack_params
        temp = {}

        ps.each do |key, value|
          outer_key, inner_key = key.scan(/^(.+)\[(.*?)\]$/).first
          if outer_key and inner_key
            temp[outer_key] ||= {}
            temp[outer_key][inner_key] = value
          else
            temp[key] = value
          end
        end

        temp
      end
    end
  end
end
