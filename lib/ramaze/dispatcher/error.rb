#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher
    class Error
      class << self
        trait :last_error => nil

        def process error
          log_error(error)

          Thread.current[:exception] = error
          handle_error = Dispatcher.trait[:handle_error]

          key = error.class.ancestors.find{|a| handle_error[a]}
          status, path = *handle_error[key || Exception]

          unless error.message =~ %r(`#{path.split('/').last}')
            Response.current.status = status
            return Dispatcher.dispatch_to(path) if path and Global.error_page
          end

          Dispatcher.build_response(error.message, status)
        rescue Object => ex
          Inform.error(ex)
          Dispatcher.build_response(ex.message, status || 500)
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
      end
    end
  end
end
