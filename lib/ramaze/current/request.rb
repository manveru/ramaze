#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'rack/request'

module Ramaze

  # The purpose of this class is to act as a simple wrapper for Rack::Request
  # and provide some convinient methods for our own use.

  class Request < ::Rack::Request
    class << self

      # get the current request out of Thread.current[:request]
      #
      # You can call this from everywhere with Ramaze::Request.current

      def current() Current.request end
    end

    # you can access the original @request via this method_missing,
    # first it tries to match your method with any of the HTTP parameters
    # then, in case that fails, it will relay to @request

    def method_missing meth, *args
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
    LOCAL = (ipv4 + ipv6).map{|a| IPAddr.new(a)} unless defined?(LOCAL)

    # --
    # Mongrel somehow puts together multiple IPs when proxy is involved.
    # ++

    def local_net?(address = ip)
      address = address.to_s.split(',').first
      addr = IPAddr.new(address)
      LOCAL.find{|range| range.include?(addr) }
    rescue ArgumentError => ex
      raise ArgumentError, ex unless ex.message == 'invalid address'
    end

    def [](key, *rest)
      value = params[key.to_s]
      return value if rest.empty?
      keys = rest.flatten.map{|k| k.to_s}
      Array[value, *params.values_at(*keys)]
    end

    def to_ivs(*args)
      instance = Action.current.instance
      args.each do |arg|
        next unless value = self[arg]
        instance.instance_variable_set("@#{arg}", value)
      end
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
      #    name, syntax = request['paste'].values_at('name', 'syntax')
      #    paste = Paste.create_with(:name => name, :syntax => syntax)
      #    redirect '/'
      #  end
      #
      #  # Or, easier:
      #
      #  def paste
      #    paste = Paste.create_with(request['paste'])
      #    redirect '/'
      #  end

      def params
        return {} if put?
        return @ramaze_params if @ramaze_params
        
        begin
          @rack_params ||= rack_params
        rescue EOFError => ex
          @rack_params = {}
          Log.error(ex)
        end
        
        @ramaze_params = {}

        @rack_params.each do |key, value|
          if key =~ /^(.*?)(\[.*\])/
            prim, nested = $~.captures
            ref = @ramaze_params

            keys = nested.scan(/\[([^\]]+)\]/).flatten
            keys.unshift prim

            keys.each_with_index do |k, i|
              if i + 1 >= keys.size
                ref[k] = value
              else
                ref = ref[k] ||= {}
              end
            end
          else
            @ramaze_params[key] = value
          end
        end

        @ramaze_params
      end
    end

    # Interesting HTTP variables from env

    def http_vars
      env.reject{ |k,v|
        k.to_s !~ /USER|HOST|REQUEST|REMOTE|FORWARD|REFER|PATH|QUERY|VERSION|KEEP|CACHE/
      }
    end

    def to_s
      p, c, e = params.inspect, cookies.inspect, http_vars.inspect
      %{#<Ramaze::Request params=#{p} cookies=#{c} env=#{e}>}
    end
    alias inspect to_s

    def pretty_print pp
      p, c, e = params, cookies, http_vars
      pp.object_group(self){
        { 'params' => params,
          'cookies' => cookies,
          'env' => http_vars }.each do |name, hash|
          pp.breakable
          pp.text " @#{name}="
          pp.nest(name.length+3){ pp.pp_hash hash }
        end
      }
    end

    # Answers with a subset of request.params with only the key/value pairs for
    # which you pass the keys.
    # Valid keys are objects that respond to :to_s
    #
    # Example:
    #   request.params
    #   # => {'name' => 'jason', 'age' => '45', 'job' => 'lumberjack'}
    #   request.sub('name')
    #   # => {'name' => 'jason'}
    #   request.sub(:name, :job)
    #   # => {'name' => 'jason', 'job' => 'lumberjack'}

    def subset(*keys)
      keys = keys.map{|k| k.to_s }
      params.reject{|k,v| not keys.include?(k) }
    end
  end
end
