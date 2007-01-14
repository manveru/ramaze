#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'

module Ramaze
  module Dispatcher
    class << self
      include Trinity

      def handle orig_request, orig_response
        create_response(orig_response, orig_request)
      rescue Object => e
        error e

        if Global.error_page
          Error::Response.new(e)
        else
          Response.new(out = '', STATUS_CODE[:internal_error], 'Content-Type' => 'text/html')
        end
      end

      def create_response orig_response, orig_request
        setup_environment orig_response, orig_request
        fill_out
      end

      def fill_out
        path = request.request_path.squeeze('/')
        Inform.debug "Request from #{request.remote_addr}: #{path}"

        the_paths = $:.map{|way| (way/'public'/path) }
        if file = the_paths.find{|way| File.exist?(way) and File.file?(way)}
          respond_file file
        else
          respond_action path
        end
        response
      end

      def respond_file file
        response.head['Content-Type'] = ''
        response.out = File.read(file)
      end

      def respond_action path
        controller, action, params = resolve_controller(path)
        response.out = handle_controller(controller, action, params)
        response.head['Set-Cookie'] = session.export
      end

      # TODO:
      # - find a solution for def x(a = :a) which has arity -1
      #   identical to def x(*a) for some odd reason

      def resolve_action controller, paraction
        info :resolve_action, controller, paraction

        meths = controller.instance_methods(false)

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
        info :resolve_controller, path.inspect
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
            if controller.trait[:actionless] or controller.superclass.trait[:actionless]
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
        if Ramaze::Global.cache_all
          const_set('Cache', Global.cache.new) unless Cache

          key = [controller.__id__, action, params]
          if out = Cache[key]
            Inform.debug("Using Cached version for #{key.inspect}")
            return out
          end

          Inform.debug "Compiling Action: #{action} #{params.join(', ')}"
          Cache[key] = controller.handle_request(action, *params)
        else
          controller.handle_request(action, *params)
        end
      end

      def setup_environment orig_response, orig_request
        Thread.current[:response] = Response.new('', STATUS_CODE[:ok], 'Content-Type' => 'text/html')
        Thread.current[:request]  = Request.new(orig_request)
        Thread.current[:session]  = Session.new(request)
      end
    end
  end
end
