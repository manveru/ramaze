#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'

require 'ramaze/error'
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
        Exception =>
          [ STATUS_CODE["Internal Server Error"], '/error' ],
        Ramaze::Error::NoAction =>
          [ STATUS_CODE["Not Found"], '/error' ],
        Ramaze::Error::NoController =>
          [ STATUS_CODE["Not Found"], '/error' ],
      }

    Cache.add :shield

    trait :shielded => [ STATUS_CODE["Not Found"] ]

    class << self
      include Trinity

      def handle rack_request, rack_response
        setup_environment(rack_request, rack_response)

        path = request.path_info.squeeze('/')
        Inform.info("Request from #{request.remote_addr}: #{path}")

        if Global.shield
          shielded_dispatch(path)
        else
          dispatch(path)
        end
      rescue Object => error
        Dispatcher::Error.process(error)
      end

      def dispatch(path)
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

        if Global.shield
          shielded_dispatch(path)
        else
          dispatch(path)
        end
      end

      def shielded_dispatch(path)
        shield_cache = Cache.shield
        handled = shield_cache[path]
        return handled if handled

        dispatched = dispatch(path)

        unless trait[:shielded].include?(dispatched.status)
          dispatched
        else
          shield_cache[path] = dispatched
        end
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
