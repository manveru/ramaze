module Rack
  class RouteExceptions
    ROUTES = []

    PATH_INFO = 'rack.route_exceptions.path_info'.freeze
    EXCEPTION = 'rack.route_exceptions.exception'.freeze

    class << self
      def route(exception, to)
        ROUTES.delete_if{|k,v| k == exception }
        ROUTES << [exception, to]
      end

      alias []= route
    end

    def initialize(app)
      @app = app
    end

    def call(env, try_again = true)
      @app.call(env)
    rescue Exception => exception
      raise(exception) unless try_again

      ROUTES.each do |klass, to|
        next unless klass === exception
        return route(to, env, exception)
      end

      raise(exception)
    end

    def route(to, env, exception)
      env.merge!(
        PATH_INFO   => env['PATH_INFO'],
        EXCEPTION   => exception,
        'PATH_INFO' => to)
      call(env, try_again = false)
    end
  end
end
