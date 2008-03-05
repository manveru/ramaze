require 'ramaze/current/request'
require 'ramaze/current/response'
require 'ramaze/current/session'

module Ramaze
  module Current
    class << self
      include Trinity

      def call(env)
        setup(env)
        before.call if before

        if filter = Global.record
          request = Current.request
          Record << request if filter[request]
        end

        Dispatcher.handle

        finish
      ensure
        after.call if after
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

      def before(&block)
        @before = block if block
        @before
      end

      def after(&block)
        @after = block if block
        @after
      end
    end
  end
end
