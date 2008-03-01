require 'ramaze/current/request'
require 'ramaze/current/response'
require 'ramaze/current/session'

module Ramaze
  class Current
    class << self
      thread_accessor :current
    end

    include Trinity
    extend Trinity

    def initialize(env)
      Current.current = self
      self.request = Request.new(env)
      self.response = Response.new
      before if defined?(before) == 'method'
    end

    def finish
      after if defined?(after) == 'method'
      session.finish if session
      response.finish
    end
  end
end
