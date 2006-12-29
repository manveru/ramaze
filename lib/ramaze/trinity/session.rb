#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/sha2'

module Ramaze
  class Session
    SESSION_KEY = '_ramaze_session_id'
    attr_accessor :session

    # TODO: introduce some key/value cache...

    def initialize request
      @session_id = parse(request)[SESSION_KEY]
    end

    def session_id
      @session_id ||= hash
    end

    def current
      sessions[session_id] ||= {}
    end

    def sessions
      @@sessions ||= {}
    end

    def pre_parse request
      if Global.adapter == :webrick
        # input looks like this: "Set-Cookie: _ramaze__session_id=fa8cc88dafcb0973b48d4d65ef57e7d3\r\n"
        cookie = request.raw_header.grep(/Set-Cookie/).first rescue ''
        cookie.to_s.gsub(/Set-Cookie: (.*?)\r\n/, '\1')
      else
        cookie = (request.http_cookie rescue request.http_set_cookie rescue '') || ''
      end
    end

    def parse request
      cookie = pre_parse(request)
      cookie.split('; ').inject({}) do |s,v| 
        key, value = v.split('=')
        s.merge key.strip => value
      end
    rescue
      Logger.error $!
      {SESSION_KEY => hash}
    end

    def method_missing meth, *args, &block
      current.send(meth, *args, &block)
    end

    def inspect
      tmp = current.clone
      tmp.delete SESSION_KEY
      tmp.inspect
    end

    def export
      "#{SESSION_KEY}=#{session_id}"
    end

    def hash
      h = [
        Time.now.to_f.to_s.reverse, rand,
        Thread.current[:request].hash, rand,
        Process.pid, rand,
        object_id, rand
      ].join
      Digest::SHA512.hexdigest(h)
    end
  end
end
