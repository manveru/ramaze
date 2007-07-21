#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

if RUBY_VERSION >= "1.9.0"
  require 'digest/sha1'
else
  require 'digest/sha2'
end

module Ramaze

  # The SessionHash acts as the wrapper for a simple Hash
  #
  # Its purpose is to notify the underlying cache, in which the sessions
  # are stored, about updates.

  class SessionHash

    # Sets @hash to an empty Hash

    def initialize
      @hash = {}
    end

    # relays all the methods to the @hash and updates the session_cache in
    # Session.current.sessions if anything changes.

    def method_missing(*args, &block)
      old = @hash.dup
      result = @hash.send(*args, &block)
      unless old == @hash
        Cache.sessions[Session.current.session_id] = self
      end
      result
    end

    # Calls #inspect on the wrapped @hash

    def inspect
      @hash.inspect
    end
  end

  # The purpose of Session is to hold key/value pairs like a Hash for a series
  # of # request/response cycles from the same client.
  #
  # The persistence is achieved by setting a cookie with the session_id to
  # the client, which is then passed back and forth until the cookie is either
  # deleted or expires.

  class Session

    # The unique id for the current session which is also passed on to the cookie.

    attr_accessor :session_id

    # This variable holds the current SessionFlash

    attr_accessor :flash

    # the key used for the cookie

    SESSION_KEY = '_ramaze_session_id'

    # Holds counter for IPs

    IP_COUNT = Hash.new{|h,k| h[k] = []}

    # Limit the number of sessions one IP is allowed to hold.

    IP_COUNT_LIMIT = 1000

    class << self

      # called from Ramaze::startup and adds Cache.sessions if cookies are
      # enabled

      def startup(options = {})
        Cache.add(:sessions) if Global.cookies
      end

      # answers with Thread.current[:session] which holds the current session
      # set by the Dispatcher#setup_environment.

      def current
        Thread.current[:session]
      end
    end

    # Initialize a new Session, requires the original Rack::Request instance
    # given to us from Dispatcher#setup_environment.
    #
    # sets @session_id and @session_flash

    def initialize request
      @session_id = (request.cookies[SESSION_KEY] || random_key)

      ip = request.remote_addr
      IP_COUNT[ip] << @session_id

      if IP_COUNT[ip].size > IP_COUNT_LIMIT
        sessions.delete(IP_COUNT[ip].shift)
      end

      @flash = Ramaze::SessionFlash.new
    end

    # relay all messages we don't understand to the currently active session

    def method_missing(*args, &block)
      current.send(*args, &block)
    end

    # answers with the currently active session, which is set unless it is
    # existing already, the session itself is an instance of SessionHash

    def current
      sessions[session_id] ||= SessionHash.new
    end

    # shortcut to Cache.sessions

    def sessions
      Cache.sessions
    end

    # generate a random (and hopefully unique) id for the current session.
    #
    # It consists of the current time, the current request, the current PID of
    # ruby and object_id of this instance.
    #
    # All this is joined by some calls to Kernel#rand and returned as a
    # Digest::SHA256::hexdigest

    def random_key
      h = [
        Time.now.to_f.to_s, rand,
        Thread.current[:request].hash, rand,
        Process.pid, rand,
        object_id, rand
      ].join
      Digest::SHA256.hexdigest(h)
    end

    # Inspect on Session.current

    def inspect
      current.inspect
    end

    # at the end of a request delete the current[:FLASH] and assign it to
    # current[:FLASH_PREVIOUS]
    #
    # this is needed so flash can iterate over requests
    # and always just keep the current and previous key/value pairs.

    def finalize
      old = current.delete(:FLASH)
      current[:FLASH_PREVIOUS] = old if old
    end
  end

  # The purpose of this class is to act as a unifier of the previous
  # and current flash.
  #
  # Flash means pairs of keys and values that are held only over one
  # request/response cycle. So you can assign a key/value in the current
  # session and retrieve it in the current and following request.
  #
  # Please see the FlashHelper for details on the usage as you won't need
  # to touch this class at all.

  class SessionFlash

    # the current session[:FLASH_PREVIOUS]

    def previous
      session[:FLASH_PREVIOUS] || {}
    end

    # the current session[:FLASH]

    def current
      session[:FLASH] ||= {}
    end

    # combined key/value pairs of previous and current
    # current keys overshadow the old ones.

    def combined
      previous.merge(current)
    end

    # flash[key] in your Controller

    def [](key)
      combined[key]
    end

    # flash[key] = value in your Controller

    def []=(key, value)
      prev = session[:FLASH] || {}
      prev[key] = value
      session[:FLASH] = prev
    end

    # Inspects the combined SessionFlash

    def inspect
      combined.inspect
    end

    private

    # Session.current or {}

    def session
      Session.current || {}
    end
  end
end
