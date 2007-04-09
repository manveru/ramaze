module Ramaze
  module Dispatcher
    class Error
      def initialize error
        @error = error
      end

      def process
        Informer.error @error
        Informer.debug "handle_error(#{@error.inspect})"
        Thread.current[:exception] = @error

        handle_error = Dispatcher.trait[:handle_error]

        Response.current.status = STATUS_CODE[:internal_server_error]

        case exception
        when *handle_error.keys
          error_path = handle_error[exception.class]
          error_path ||= handle_error.find{|k,v| k === exception}.last

          if exception.message =~ /`#{error_path.split('/').last}'/
            build_response(exception.message)
          else
            dispatch_to error_path
          end
        else
          if Global.error_page
            dispatch_to '/error'
          else
            build_response(exception.message)
          end
        end
      rescue Object => ex
        Informer.error ex
        build_response(ex.message)
      end

      def build_response *args
        Dispatcher.build_response(*args)
      end
    end
  end
end
