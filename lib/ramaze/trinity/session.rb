#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/sha2'

class Ramaze::Session
  SESSION_KEY = '_ramaze_session_id'

  class << self
    def current
      Thread.current[:session]
    end
  end

  def initialize request
    @session_id = (request.cookies[SESSION_KEY] || random_key)
  end

  def session_id
    @session_id
  end

  # tries to catch all methods and proxy them to the #current
  # this makes it easier to do i.e. hash-manipulation directly
  # on #session in the controller.

=begin
  def method_missing meth, *args, &block
    current.send(meth, *args, &block)
  end
=end

  def [](key)
    current[key]
  end

  def []=(key, value)
    current[key] = value
  end

  def merge!(hash = {})
    current.merge! hash
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
    Thread.main[:session_cache] ||= constant(Global.cache.to_s).new
  end

  def export
    "#{SESSION_KEY}=#{session_id}"
  end

  def random_key
    h = [
      Time.now.to_f.to_s.reverse, rand,
      Thread.current[:request].hash, rand,
      Process.pid, rand,
      object_id, rand
    ].join
    Digest::SHA512.hexdigest(h)
  end

  def inspect
    tmp = current.clone
    tmp.delete SESSION_KEY
    tmp.inspect
  end
end

=begin
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

      # Get the current session out of Thread.current[:session]
      #
      # You can call this from everywhere with Ramaze::Session.current

      def current
        Thread.current[:session]
      end
    end

    # pass the request-object and it will extract the session-id (which is
    # stored in the cookie with the key of SESSION_KEY

    def initialize request
      @session_id = get_cookie(request)[SESSION_KEY]
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
      Thread.main[:session_cache] ||= constant(Global.cache.to_s).new
    end

    def get_cookie request
      cookies = request.cookies
      cookie = cookies[SESSION_KEY]
      cookie || {SESSION_KEY => session_key}
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

    def session_key
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
=end
