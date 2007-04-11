#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher
    class Error
      class << self
        def process error
          Informer.error error
          Informer.debug "handle_error(#{error.inspect})"
          Thread.current[:exception] = error

          handle_error = Dispatcher.trait[:handle_error]

          Response.current.status = STATUS_CODE[:internal_server_error]

          case error
          when *handle_error.keys
            error_path = handle_error[error.class]
            error_path ||= handle_error.find{|k,v| k === error}.last

            if error.message =~ /`#{error_path.split('/').last}'/
              build_response(error.message)
            else
              Dispatcher.dispatch_to(error_path)
            end
          else
            if Global.error_page
              Dispatcher.dispatch_to('/error')
            else
              build_response(error.message)
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
end
