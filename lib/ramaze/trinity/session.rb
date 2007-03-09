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
    @session_flash = Ramaze::SessionFlash.new
  end

  def session_id
    @session_id
  end

  def [](key)
    current[key]
  end

  def []=(key, value)
    current[key] = value
  end

  def merge!(hash = {})
    current.merge! hash
  end

  def clear
    current.clear
  end

  def delete key
    current.delete(key)
  end

  # the current contents of session

  def current
    sessions[session_id] ||= {}
  end

  def flash
    @session_flash
  end

  # all the sessions currently stored, in case there are none yet it will
  # set the constant Ramaze::SessionCache and from then on start populating
  # it with the sessions. SessionCache is an instance of Ramaze::Global.cache as
  # well.

  def sessions
    Thread.main[:session_cache] ||= constant("::Ramaze::#{Ramaze::Global.cache}").new
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

  def finalize
    flash_finalize
  end

  def flash_finalize
    current[:FLASH_PREVIOUS] = delete :FLASH
  end
end

class Ramaze::SessionFlash
  def previous
    session[:FLASH_PREVIOUS] ||= {}
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
