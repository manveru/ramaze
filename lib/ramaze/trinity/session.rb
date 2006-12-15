#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/md5'

module Ramaze
  class Session
    attr_accessor :session

    # TODO: introduce some key/value cache...

    def initialize request
      @session_id = parse(request)['_session_id']
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
        # input looks like this: "Set-Cookie: _session_id=fa8cc88dafcb0973b48d4d65ef57e7d3\r\n"
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
      {'_session_id' => hash}
    end

    def method_missing meth, *args, &block
      current.send(meth, *args, &block)
    end

    def inspect
      tmp = current.clone
      tmp.delete '_session_id'
      tmp.inspect
    end

    def export
      # do not use #{} here, that would evaluate the id, which is dangerous
      # since given by the user ;)
      "_session_id=" + session_id.to_s
    end

    def hash
      hash = []
      hash << rand * rand ** rand / rand
      hash << Time.now.hash
      hash << 'salt_n_pepper'
      Digest::MD5.hexdigest(hash.join(rand.to_s))
    end
  end
end
