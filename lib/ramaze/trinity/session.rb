#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'digest/sha2'

module Ramaze
  class TriggerHash
    def initialize
      @hash = {}
    end

    def method_missing(*args, &block)
      old = @hash.dup
      result = @hash.send(*args, &block)
      unless old == @hash
        Thread.main[:session_cache][Session.current.session_id] = self
      end
      result
    end

    def inspect
      @hash.inspect
    end
  end

  class Session
    attr_accessor :session_id
    SESSION_KEY = '_ramaze_session_id'

    class << self
      def current
        Thread.current[:session]
      end
    end

    def initialize request
      @session_id = (request.cookies[SESSION_KEY] || random_key)
      @session_flash = Ramaze::SessionFlash.new

      unless sessions
        global_cache = Ramaze::Global.cache

        if global_cache.respond_to?(:new)
          cache = global_cache.new
        else
          cache = constant("::Ramaze::#{global_cache}")
          cache = cache.new if cache.respond_to?(:new)
        end

        Thread.main[:session_cache] = cache
      end
    end

    def method_missing(*args, &block)
      current.send(*args, &block)
    end

    def current
      sessions[session_id] ||= TriggerHash.new
    end

    def sessions
      Thread.main[:session_cache]
    end

    def random_key
      h = [
        Time.now.to_f.to_s.reverse, rand,
        Thread.current[:request].hash, rand,
        Process.pid, rand,
        object_id, rand
      ].join
      Digest::SHA256.hexdigest(h)
    end

    def flash
      @session_flash
    end

    def finalize
      flash_finalize
    end

    def flash_finalize
      old = delete(:FLASH)
      current[:FLASH_PREVIOUS] = old if old
    end

    def inspect
      current.inspect
    end
  end

  class SessionFlash
    def previous
      session[:FLASH_PREVIOUS] || {}
    end

    def current
      session[:FLASH] ||= {}
    end

    def combined
      previous.merge(current)
    end

    def [](key)
      combined[key]
    end

    def []=(key, value)
      current[key] = value
    end

    def session
      Ramaze::Session.current
    end

    def inspect
      combined.inspect
    end
  end
end
