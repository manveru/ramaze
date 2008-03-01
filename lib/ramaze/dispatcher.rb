#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/error'
require 'ramaze/tool/mime'

require 'ramaze/dispatcher/action'
require 'ramaze/dispatcher/error'
require 'ramaze/dispatcher/file'
require 'ramaze/dispatcher/directory'

module Ramaze

  # The Dispatcher receives requests from adapters and sets up the proper environment
  # to process them and respond.

  module Dispatcher

    # requests are passed to every
    FILTER = [ Dispatcher::File, Dispatcher::Action ] unless defined?(FILTER)

    # Response codes to cache the output of for repeated requests.
    trait :shielded => [ STATUS_CODE["Not Found"] ]

    class << self
      include Trinity

      # Entry point for Adapter#respond, takes a Rack::Request and
      # Rack::Response, sets up the environment and the goes on to dispatch
      # for the given path from rack_request.
      def handle
        path = request.path_info.squeeze('/')

        case path
        when *Global.ignore
          unless ::File.exist?(Dispatcher::File.resolve_path(path))
            return response.build(Global.ignore_body, Global.ignore_status)
          end
        end

        general_dispatch path
      rescue Object => error
        meta = { :path => path,
                 :request => request,
                 :controller => Thread.current[:controller] }
        Dispatcher::Error.process(error, meta)
      end

      # protcets against recursive dispatch and reassigns the path_info in the
      # request, the rest of the request is kept intact.
      def dispatch_to(path)
        if request.path_info == path
          if error = Thread.current[:exception]
            raise error
          else
            raise "Recursive redirect from #{path} to #{path}"
          end
        end
        request.path_info = path
        general_dispatch path
      end

      # splits up the dispatch based on Global.shield
      def general_dispatch(path)
        if Global.shield
          shielded_dispatch path
        else
          dispatch path
        end
      end

      # Protects somewhat against hammering of erroring paths, since error-pages
      # take a while to build in the default mode it is possible to decrease
      # overall speed quite a bit by hitting Ramaze with such paths.
      # shielded_dispatch checks the path and caches erronous responses so they
      # won't be recreated but simply pushed out again without stopping at the
      # Controller.
      # Please note that this is just minor protection and the best option is to
      # create a performant error-page instead.
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

      # filters the path until a response or redirect is thrown or a filter is
      # successful, builds a response from the returned hash in case of throws.
      def dispatch(path)
        catch(:respond){
          redirected = catch(:redirect){
            filter(path)
            throw(:respond)
          }
          response.build(*redirected)
        }
      end

      # Calls .process(path) on every class in Dispatcher::FILTER until one
      # returns something else than false/nil.

      def filter(path)
        result = nil
        FILTER.each do |dispatcher|
          result = dispatcher.process(path)
          return result if result and not result.respond_to?(:exception)
        end

        meta = {
          :path => path,
          :controller => Thread.current[:controller]
        }
        Dispatcher::Error.process(result, meta)
      end
    end
  end
end
