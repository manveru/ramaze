require 'ramaze/current/request'
require 'ramaze/current/response'
require 'ramaze/current/session'

module Ramaze
  module Current
    class << self
      include Trinity

      def call(env)
        setup(env)
        before_call

        if filter = Global.record
          request = Current.request
          Record << request if filter[request]
        end

        Dispatcher.handle

        finish
      ensure
        after_call
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

      def before_call
        if before
          begin
            before.call
          rescue Object => e
            Ramaze::Log.error e
            raise
          end
        end
      end

      def after(&block)
        @after = block if block
        @after
      end

      def after_call
        if after
          begin
            after.call
          rescue Object => e
            Ramaze::Log.error e
            raise
          end
        end
      end
    end
  end
end
