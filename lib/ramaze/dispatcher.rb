#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'

module Ramaze
  module Dispatcher
    class << self
      include Trinity

      def handle orig_request, orig_response
        @orig_request, @orig_response = orig_request, orig_response
        create_response(orig_response, orig_request)
      rescue Object => exception
        error(exception)
        handle_error(exception)
      end

      def handle_error exception
        meth_debug :handle_error, exception
        Thread.current[:exception] = exception

        case exception
        when nil #Error::NoAction, Error::NoController
          Response.new(exception.message, STATUS_CODE[:not_found], 'Content-Type' => 'text/plain')
        else
          if Global.error_page
            Thread.current[:request].request.params['REQUEST_PATH'] = '/error'
            fill_out
          else
            Response.new(exception.message, STATUS_CODE[:internal_server_error], 'Content-Type' => 'text/plain')
          end
        end
      end

      def create_response orig_response, orig_request
        setup_environment orig_response, orig_request
        fill_out
      end

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

      def respond_file file
        debug "Responding with static file: #{file}"

        response.head['Content-Type'] = ''
        if Global.adapter == :mongrel
          @orig_response.send_file(file)
        else
          response.out = File.read(file)
        end
      end

      def respond_action path
        debug "Responding with action: #{path}"

        controller, action, params = resolve_controller(path)
        response.head['Set-Cookie'] = session.export if Global.cookies

        catch :respond do
          response.out = handle_controller(controller, action, params)
        end
      end

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
            if controller.trait[:actionless] or
              controller.superclass.trait[:actionless] or
              paraction == ['error']

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

      def handle_controller controller, action, params
        if Global.cache_all or Global.cache_actions[controller].include?(action.to_s)
          handle_cached_controller(controller, action, *params)
        else
          handle_uncached_controller(controller, action, *params)
        end
      end

      def handle_uncached_controller controller, action, *params
        controller.handle_request(action, *params)
      end

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

      def setup_environment orig_response, orig_request
        this = Thread.current
        this[:response] = Response.new('', STATUS_CODE[:ok], 'Content-Type' => 'text/html')
        this[:request]  = Request.new(orig_request)
        this[:session]  = Session.new(request)
      end
    end
  end
end
