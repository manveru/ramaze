#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher
    class Error
      HANDLE_ERROR = {
                          Exception => [ 500, '/error' ],
            Ramaze::Error::NoAction => [ 404, '/error' ],
        Ramaze::Error::NoController => [ 404, '/error' ],
      }

      class << self
        trait :last_error => nil

        def process(error, metainfo = {})
          log_error(error)

          Thread.current[:exception] = error

          key = error.class.ancestors.find{|a| HANDLE_ERROR[a]}
          status, path = *HANDLE_ERROR[key || Exception]
          status ||= 500

          if controller = metainfo[:controller]
            begin
              action = Controller.resolve(controller.mapping + path)
              return Dispatcher.build_response(action.render, status)
            rescue Ramaze::Error
              Inform.debug("No custom error page found on #{controller}, going to #{path}")
            end
          end

          unless error.message =~ %r(`#{path.split('/').last}')
            Response.current.status = status
            return Dispatcher.dispatch_to(path) if path and Global.error_page
          end

          Dispatcher.build_response(error.message, status)
        rescue Object => ex
          Inform.error(ex)
          Dispatcher.build_response(ex.message, status)
        end

        def log_error error
          error_message = error.message

          if trait[:last_error] == error_message
            Inform.error(error_message)
          else
            trait[:last_error] = error_message
            Inform.error(error)
          end
        end

        def current
          Thread.current[:exception]
        end

      end
    end
  end
end
