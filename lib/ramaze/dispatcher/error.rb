#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Dispatcher
    class Error
      class << self
        def process error
          Inform.error(error)
          Inform.debug("handle_error(#{error.inspect})")
          Thread.current[:exception] = error

          handle_error = Dispatcher.trait[:handle_error]

          key = error.class.ancestors.find{|a| handle_error[a]}
          status, path = *handle_error[key || Exception]

          error_in_error = error.message =~ /`#{path.split('/').last}'/

          Response.current.status = status

          unless error_in_error
            return Dispatcher.dispatch_to(path) if path and Global.error_page
          end

          Dispatcher.build_response(error.message, status)
        rescue Object => ex
          Inform.error(ex)
          Dispatcher.build_response(ex.message, status)
        end
      end
    end
  end
end
