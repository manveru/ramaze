#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher

    # Last resort dispatcher, tries to recover as much information as possible
    # from the past request and takes the appropiate actions.
    #
    # You can configure it over the HANDLE_ERROR constant or by defining error
    # actions in your controllers.

    class Error

      # The class of exception is matched when an error occurs and the status
      # code is set. The absolute URLs are used as fallback in case of a total
      # failure.
      HANDLE_ERROR = {
                          Exception => [ 500, '/error' ],
            Ramaze::Error::NoAction => [ 404, '/error' ],
        Ramaze::Error::NoController => [ 404, '/error' ],
      }

      class << self
        trait :last_error => nil

        # Takes exception, of metainfo only :controller is used at the moment.
        # Then goes on to try and find the correct response status and path.
        # In case metainfo has a controller we try to get the action for the
        # path on it, dispatching there if we find one.
        # Otherwise a plain-text error message is set as response.
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
            rescue Ramaze::Error => e
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

        # Only logs new errors with full backtrace, repeated errors are shown
        # only with their message.
        def log_error error
          error_message = error.message

          if trait[:last_error] == error_message
            Inform.error(error_message)
          else
            trait[:last_error] = error_message
            Inform.error(error)
          end
        end

        # Handle to current exception.
        # Only works inside request/response cycle.
        def current
          Thread.current[:exception]
        end

      end
    end
  end
end
