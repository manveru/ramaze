#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/sha2'

module Ramaze

  # Session is the object that stores all the session-information of the user.
  # It is heavily based on cookies storing the key to the information stored
  # on the server.
  #
  # It uses caching as set in Global.cache and tries to set a cookie in case
  # there is none set yet.

  class Session
    SESSION_KEY = '_ramaze_session_id'
    attr_accessor :session

    class << self

      # the current session, you can call this from everywhere with Ramaze::Session.current

      def current
        Thread.current[:session]
      end
    end

    # pass the request-object and it will extract the session-id (which is
    # stored in the cookie with the key of SESSION_KEY

    def initialize request
      @session_id = parse(request)[SESSION_KEY]
    end

    # current session_id, will generate a new one based on #hash if no session
    # is currently active

    def session_id
      @session_id ||= hash
    end

    # the current contents of session

    def current
      sessions[session_id] ||= {}
    end

    # all the sessions currently stored, in case there are none yet it will
    # set the constant Ramaze::SessionCache and from then on start populating
    # it with the sessions. SessionCache is an instance of Global.cache as
    # well.

    def sessions
      silently do
        Ramaze.const_set('SessionCache', Global.cache.new) unless SessionCache
      end

      SessionCache
    end

    # this runs before #parse and will extract the information stored in the cookie
    # of the client, in case there is none it will try to set one.
    # Unfortunatly we have to go seperate paths here for mongrel and webrick,
    # since they do not share the same API.

    def pre_parse request
      if Global.adapter == :webrick
        # input looks like this:
        #   "Set-Cookie: _ramaze__session_id=fa8cc88dafcb0973b48d4d65ef57e7d3\r\n"
        cookie = request.raw_header.grep(/Set-Cookie/).first rescue ''
        cookie.to_s.gsub(/Set-Cookie: (.*?)\r\n/, '\1')
      else
        cookie = (request.http_cookie rescue request.http_set_cookie rescue '') || ''
      end
    end

    # parse the cookie and extract all the variables stored in there.

    def parse request
      cookie = pre_parse(request)
      cookie.split('; ').inject({}) do |s,v|
        key, value = v.split('=')
        s.merge key.strip => value
      end
    rescue
      Inform.error $!
      {SESSION_KEY => hash}
    end

    # tries to catch all methods and proxy them to the #current
    # this makes it easier to do i.e. hash-manipulation directly
    # on #session in the controller.

    def method_missing meth, *args, &block
      current.send(meth, *args, &block)
    end

    # show the contents of the session without key/value of the cookie

    def inspect
      tmp = current.clone
      tmp.delete SESSION_KEY
      tmp.inspect
    end

    # show only the key/value of the cookie, useful for debugging.

    def export
      "#{SESSION_KEY}=#{session_id}"
    end

    # generate an unique #hash for the current session

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
