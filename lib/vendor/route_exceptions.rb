module Rack
  class RouteExceptions
    ROUTES = []

    ROUTE_EXCEPTIONS_PATH_INFO = 'rack.route_exceptions.path_info'.freeze
    ROUTE_EXCEPTIONS_EXCEPTION = 'rack.route_exceptions.exception'.freeze
    ROUTE_EXCEPTIONS_RETURNED  = 'rack.route_exceptions.returned'.freeze

    def initialize(app)
      @app = app
    end

    def call(env, try_again = true)
      returned = @app.call(env)
    rescue Exception => exception
      raise(exception) unless try_again

      ROUTES.each do |klass, to|
        next unless klass === exception
        return route(to, env, returned, exception)
      end

      raise(exception)
    end

    def route(to, env, returned, exception)
      hash = {
        ROUTE_EXCEPTIONS_PATH_INFO => env['PATH_INFO'],
        ROUTE_EXCEPTIONS_EXCEPTION => exception,
        ROUTE_EXCEPTIONS_RETURNED => returned
      }
      env.merge!(hash)

      env['PATH_INFO'] = to

      call(env, try_again = false)
    end

    def self.route(exception, to)
      ROUTES.delete_if{|k,v| k == exception }
      ROUTES << [exception, to]
    end

    alias []= route
  end
end
