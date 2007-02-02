#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'

module Ramaze

  # The Dispatcher is the very heart of Ramaze itself.
  #
  # It will take requests and guide the request through all parts of the
  # framework and your application.
  #
  # It is built in a way that lets you easily replace it with something you
  # like better, since i'm very fond of the current implementation you can't
  # find any examples of how this is done exactly yet.

  module Dispatcher
    class << self
      include Trinity

      # handle a request/response pair as given by the adapter.
      # has to answer with a response.
      #
      # It is built so it will catch _all_ errors and exceptions
      # thrown during processing of the request and #handle_error if
      # a problem occurs.

      def handle orig_request, orig_response
        @orig_request, @orig_response = orig_request, orig_response
        respond(orig_response, orig_request)
      rescue Object => exception
        error(exception)
        handle_error(exception)
      end

      # The handle_error method takes an exception and decides based on that
      # how it is going to respond in case of an error.
      #
      # In future this will become more and more configurable, right now
      # you can provide your own error-method and error.xhtml inside either
      # your trait[:template_root] or trait[:public].
      #
      # As more and more error-classes are being added to Ramaze you will get
      # the ability to define your own response-pages and/or behaviour like
      # automatic redirects.
      #
      # This feature is only available if your Global.error is true, which is
      # the default.
      #
      # Yes, again, webrick _has_ to be really obscure, I searched for half an hour
      # and still have not the faintest idea how request_path is related to
      # request_uri...
      # anyway, the solution might be simple?

      def handle_error exception
        meth_debug :handle_error, exception
        Thread.current[:exception] = exception

        case exception
        when nil #Error::NoAction, Error::NoController
          build_response(exception.message, STATUS_CODE[:not_found])
        else
          if Global.error_page
            req = Thread.current[:request]

            unless (req.request_uri.path = '/error') rescue false
              req.request.params['REQUEST_PATH'] = '/error'
            end

            fill_out
          else
            build_response(exception.message, STATUS_CODE[:internal_server_error])
          end
        end
      end

      # setup the #setup_environment (Trinity) and start #fill_out

      def respond orig_response, orig_request
        setup_environment orig_response, orig_request
        fill_out
      end

      #

      def build_response out = '', code = STATUS_CODE[:internal_server_error], head = {}
        default_head = {
          'Content-Type' => 'text/plain',
        }

        if Global.cookies
          default_head['Set-Cookie'] = session.export
        else
          head.delete('Set-Cookie')
        end

        head = default_head.merge(head)

        Response.new(out, code, head)
      end


      # Obtain the path requested from the request and search for a static
      # file matching the request, #respond_file is called if it finds one,
      # otherwise the path is given on to #respond_action.
      # Answers with a response

      def fill_out
        path = request.request_path.squeeze('/')
        info "Request from #{request.remote_addr}: #{path}"

        the_paths = $:.map{|way| (way/'public'/path) }
        if file = the_paths.find{|way| File.exist?(way) and File.file?(way)}
          respond_file file
        else
          respond_action path
        end
        response
      end

      # takes a file and sets the response.out to the contents of the file
      # If you are running mongrel as your adapter it will take advantage of
      # mongrels #send_file

      def respond_file file
        debug "Responding with static file: #{file}"

        response.head['Content-Type'] = ''
        if @orig_response.respond_to?(:send_file)
          @orig_response.send_file(file)
        else
          response.out = File.read(file)
        end
      end

      # Takes the path, figures out the controller by asking #resolve_controller
      # for the controller, action and params for the path.
      #
      # Sets the cookies in the response.head if Global.cookies is set
      #
      # finally it runs #handle_controller

      def respond_action path
        debug "Responding with action: #{path}"

        controller, action, params = resolve_controller(path)
        catch :respond do
          response.out = handle_controller(controller, action, params)
        end
      end

      # find out which controller should be used based on the path.
      # it will answer [controller, action, params] or raise an
      #
      #   Ramaze::Error::NoController # if no controller is found
      #   Ramaze::Error::NoAction     # if no action but a controller is found
      #
      # It actually uses #resolve_action on almost every combination of
      # so-called paractions (yet unsplit but possible combination of action
      # and parameters for the action)
      #
      # If your templating is action-less, which means it does not depend on
      # methods on the controller, but rather on templates or just dynamically
      # calculated stuff you can set trait[:actionless] for your templating.
      #
      # Please see the documentation for Ramaze::Template::Amrita2 for an more
      # specific example of how it is used in practice.
      #
      # Further it uses the Global.mapping to look up the controller to be used.
      #
      # Also, the action '/' will be expanded to 'index'
      #
      # Parameters are CGI.unescaped

      def resolve_controller path
        meth_debug :resolve_controller, path
        track = path.split('/')
        controller = false
        action = false
        tracks = []

        track.unshift '/'

        track.each do |atom|
          tracks << (tracks.last.to_s / atom)
        end

        until controller and action or tracks.empty?
          current = Regexp.escape(tracks.pop.to_s)
          paraction = path.gsub(/^#{current}/, '').split('/').map{|e| CGI.unescape(e)}
          paraction.delete('')
          if controller = Ramaze::Global.mapping[current]
            if controller.ancestral_trait[:actionless] or paraction == ['error']

              action = paraction.shift
              params = paraction
              action = 'index' if action == nil
            else
              action, params = resolve_action controller, paraction
            end
          end
        end

        raise Ramaze::Error::NoController, "No Controller found for #{path}" unless controller
        raise Ramaze::Error::NoAction, "No Action found for #{path}" unless action

        return controller, action, params
      end

      # Resolve the method to be called and the number of parameters
      # it will receive for a specific class (the controller) given the
      # paraction (like 'foo/bar' => controller.call('foo', 'bar'))
      # in case arity is 1 and a public instance-method named foo is defined.
      #
      # TODO:
      # - find a solution for def x(a = :a) which has arity -1
      #   identical to def x(*a) for some odd reason

      def resolve_action controller, paraction
        meth_debug :resolve_action, controller, paraction

        meths =
          (controller.ancestors - [Kernel, Object]).inject([]) do |sum, klass|
            sum | (klass.is_a?(Module) ? klass.instance_methods(false) : sum)
          end

        track = paraction.dup
        tracks = []
        action = false

        track.each do |atom|
          atom = [tracks.last.to_s, atom]
          atom.delete('')
          tracks << atom.join('__')
        end

        tracks.unshift 'index'

        until action or tracks.empty?
          current = tracks.pop
          if meths.include?(current)
            arity = controller.instance_method(current).arity
            params = (paraction - current.split('__'))

            if params.size == arity
              return current, params
            elsif arity < 0 and arity + params.size >= 0
              return current, params
            elsif arity == -1
              return current, params
            end
          end
        end
      end

      # Depending on Global.cache_all and Global.cache_actions it will
      # call either #handle_uncached_controller or #handle_cached_controller
      # takes the controller, action and params and just passes them on.

      def handle_controller controller, action, params
        if Global.cache_all or Global.cache_actions[controller].include?(action.to_s)
          handle_cached_controller(controller, action, *params)
        else
          handle_uncached_controller(controller, action, *params)
        end
      end

      # Call the class-method handle_request with action and *params, all
      # the controller has to do is to respond with a string.

      def handle_uncached_controller controller, action, *params
        controller.handle_request(action, *params)
      end

      # Call the class-method handle_request with action and *params, all
      # the controller has to do is to respond with a string.
      #
      # To add a method for caching you can either use the CacheHelper
      # or directly
      #   Global.cache_actions[self] << 'index'
      #
      # Caching is done for [action, params] pairs per controller.

      def handle_cached_controller controller, action, *params
        Global.cached_actions ||= Global.cache.new

        key = [action, params].inspect

        Global.cached_actions[controller] ||= {key => nil}

        if out = Global.cached_actions[controller][key]
          debug "Using Cached version for #{key.inspect}"
          return out
        end

        debug "Compiling Action: #{action} #{params.join(', ')}"
        Global.cached_actions[controller][key] =
          handle_uncached_controller(controller, action, *params)
      end

      # Setup the Trinity (Request, Response, Session) and store them as
      # thread-variables in Thread.current
      #   Thread.current[:request]  == Request.current
      #   Thread.current[:response] == Response.current
      #   Thread.current[:session]  == Session.current

      def setup_environment orig_response, orig_request
        this = Thread.current
        this[:response] = build_response('', STATUS_CODE[:ok], 'Content-Type' => 'text/html')
        this[:request]  = Request.new(orig_request)
        this[:session]  = Session.new(request)
      end
    end
  end
end
