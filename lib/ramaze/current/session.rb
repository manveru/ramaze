#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

if RUBY_VERSION >= "1.9.0"
  require 'digest/sha1'
else
  require 'digest/sha2'
end

require 'ramaze/current/session/flash'
require 'ramaze/current/session/hash'

module Ramaze

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

    # secret salt for client-side session data

    trait :secret => 'change_me_please_123'

    # the key used for the cookie

    SESSION_KEY = '_ramaze_session_id' unless defined?(SESSION_KEY)

    # Holds counter for IPs

    IP_COUNT = ::Hash.new{|h,k| h[k] = OrderedSet.new} unless defined?(IP_COUNT)

    # Limit the number of sessions one IP is allowed to hold.

    IP_COUNT_LIMIT = 1000 unless defined?(IP_COUNT_LIMIT)

    # Holds the default cookie used for sessions

    COOKIE = { :path => '/' }

    class << self
      # Shortcut for Current.session
      def current
        Current.session
      end

      # called from Ramaze::startup and adds Cache.sessions if cookies are
      # enabled

      def startup(options = {})
        Cache.add(:sessions) if Global.sessions
      end
    end

    # Initialize a new Session, requires the original Rack::Request instance
    # given to us from Dispatcher#setup_environment.
    #
    # sets @session_id and @session_flash

    def initialize(request = Current.request)
      return unless Global.sessions
      @session_id = (request.cookies[SESSION_KEY] || random_key)

      unless IP_COUNT.nil?
        ip = request.ip
        IP_COUNT[ip] << @session_id
        sessions.delete(IP_COUNT[ip].shift) if IP_COUNT[ip].size > IP_COUNT_LIMIT
      end

      @flash = Ramaze::Session::Flash.new
    end

    # relay all messages we don't understand to the currently active session

    def method_missing(*args, &block)
      current.send(*args, &block)
    end

    # answers with the currently active session, which is set unless it is
    # existing already, the session itself is an instance of SessionHash

    def current
      sessions[session_id] ||= Session::Hash.new
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
        Current.request.hash, rand,
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
    #
    # finalizes the session and assigns the key to the response via
    # set_cookie.

    def finish
      return unless Global.sessions

      old = current.delete(:FLASH)
      current[:FLASH_PREVIOUS] = old if old

      request, response = Current.request, Current.response

      hash = {:value => session_id}.merge(COOKIE)
      response.set_cookie(SESSION_KEY, hash)

      # set client side session cookie
      if val = request['session.client'] and
         (!val.empty? or request.cookies["#{SESSION_KEY}-client"])
        cookie = hash.merge(:value => marshal(val))
        response.set_cookie("#{SESSION_KEY}-client", cookie)
      end
    end
  end
end
