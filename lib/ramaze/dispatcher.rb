#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'

require 'ramaze/adapter'
require 'ramaze/tool/mime'

require 'ramaze/dispatcher/action'
require 'ramaze/dispatcher/error'
require 'ramaze/dispatcher/file'

module Ramaze
  module Dispatcher

    trait :dispatch => [
      Dispatcher::File,
      Dispatcher::Action,
    ]

    trait :handle_error => {
        Exception                   => [500, '/error'],
        Ramaze::Error::NoAction     => [404, '/error'],
        Ramaze::Error::NoController => [404, '/error'],
      }

    class << self
      include Trinity

      def handle rack_request, rack_response
        setup_environment(rack_request, rack_response)
        dispatch
      rescue Object => error
        Dispatcher::Error.process(error)
      end

      def dispatch
        path = request.path_info.squeeze('/')
        Inform.info("Request from #{request.remote_addr}: #{path}")

        catch(:respond) do
          redirection = catch(:redirect) do
            found = filter(path)
            throw(:respond, found)
          end

          body, status, head = redirection.values_at(:body, :status, :head)
          Inform.info("Redirect to `#{head['Location']}'")
          throw(:respond, build_response(body, status, head))
        end
      end

      def dispatch_to path
        raise "Redirect to #{path} from #{path}" if request.path_info == path
        request.path_info = path
        dispatch
      end

      def filter path
        trait[:dispatch].each do |dispatcher|
          result = dispatcher.process(path)
          return result if result
        end
        raise Ramaze::Error::NoAction, "No Dispatcher found for `#{path}'"
      end

      def build_response body = response.body, status = response.status, head = response.header
        set_cookie if Global.cookies
        head.each do |key, value|
          response[key] = value
        end

        response.body, response.status = body, status

        return response
      end

      def set_cookie
        session.finalize
        hash = {:value => session.session_id, :path => '/'}
        response.set_cookie(Session::SESSION_KEY, hash)
      end

      # Setup the Trinity (Request, Response, Session) and store them as
      # thread-variables in Thread.current
      #   Thread.current[:request]  == Request.current
      #   Thread.current[:response] == Response.current
      #   Thread.current[:session]  == Session.current

      def setup_environment rack_request, rack_response
        this = Thread.current
        this[:request]  = rack_request
        this[:session]  = Session.new(request)
        this[:response] = rack_response
      end
    end
  end
end
