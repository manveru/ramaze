#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'cgi'
require 'tmpdir'
require 'digest/md5'
require 'ipaddr'
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

    def request_uri
      env['REQUEST_URI'] || path_info
    end

    def ip
      env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']
    end

    # Request is from a local network?
    # Checks both IPv4 and IPv6

    ipv4 = %w[ 127.0.0.1/32 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8 169.254.0.0/16 ]
    ipv6 = %w[ fc00::/7 fe80::/10 fec0::/10 ::1 ]
    LOCAL = (ipv4 + ipv6).map{|a| IPAddr.new(a)}

    def local_net?(address = ip)
      addr = IPAddr.new(address)
      LOCAL.find{|range| range.include?(addr) }
    end

    unless method_defined?(:rack_params)
      alias rack_params params

      # Wrapping Request#params to support a one-level hash notation.
      # It doesn't support anything really fancy, so be conservative in its use.
      #
      # See if following provides something useful for us:
      # http://redhanded.hobix.com/2006/01/25.html
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
        return {} if put?
        return @ramaze_params if @ramaze_params
        @rack_params ||= rack_params
        @ramaze_params = {}

        @rack_params.each do |key, value|
          outer_key, inner_key = key.scan(/^(.+)\[(.*?)\]$/).first
          if outer_key and inner_key
            @ramaze_params[outer_key] ||= {}
            @ramaze_params[outer_key][inner_key] = value
          else
            @ramaze_params[key] = value
          end
        end

        @ramaze_params
      end
    end
  end
end
