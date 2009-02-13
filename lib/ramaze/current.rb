require 'ramaze/current/request'
require 'ramaze/current/response'
require 'ramaze/current/session'

module Ramaze
  class Current
    include Trinity
    extend Trinity

    def initialize(app)
      @app = app
    end

    def call(env)
      setup(env)
      before_call
      record

      @app.call(env)
      finish
    ensure
      after_call
    end

    def record
      return unless filter = Global.record
      request = Current.request
      Record << request if filter.call(request)
    end

    def setup(env)
      self.request = Request.new(env)
      self.response = Response.new
      self.session = Session.new
    end

    def finish
      session.finish if session
      response.finish
    end

    def self.call(env)
    end

    def before_call
    end

    def after_call
    end
  end
end
