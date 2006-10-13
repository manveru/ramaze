module Ramaze::Dispatcher
  RESPONSE = Response.create

  class << self
    def handle orig_request, orig_response
      response = create_response(orig_request)
    rescue Object => e
      error e
      response = Error::Response.new(e)
    ensure
      response
    end

    def create_response orig_request
      response = RESPONSE.clear
      request = Request.new(orig_request)

      path = request.request_path
      debug "Request from #{request.remote_addr}: #{path}"

      controller, action, params = resolve_controller(path)
      response.out = handle_controller(request, controller, action, params)
      response
    end

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

          # (*foo) or (foo = :x) or it matches
          if arity == -1 or arity == params.size
            return current, params
          end
        end
      end

      return nil, []
    end

    def resolve_controller path
      info :resolve_controller, path.inspect
      track = path.split('/')
      controller = false
      action = false
      tracks = []

      track.unshift ('/')

      track.each do |atom|
        tracks << File.join(tracks.last.to_s, atom)
      end

      until controller and action or tracks.empty?
        current = tracks.pop
        paraction = path.gsub(/^#{current}/, '').split('/')
        paraction.delete('')
        if controller = Global.mapping[current]
          action, params = resolve_action controller, paraction
        end
      end

      raise Error::NoController, "No Controller found for #{path}" unless controller
      raise Error::NoAction, "No Action found for #{path}" unless action

      return controller, action, params
    end

    def handle_controller request, controller, action, params
      if Global.cache
        Global.out_cache ||= {}

        key = [controller.__id__, action, params]
        out = Global.out_cache[key]

        return out if out

        debug "Compiling Action: #{action} #{params.join(', ')}"
        Global.out_cache[key] = request_controller request, controller, action, params
      else
        request_controller request, controller, action, params
      end
    end

    def request_controller request, controller, action, params
      controller.new(request).__send__(action, *params)
    end

    def resolve_template
      false
    end

    def handle_template action, template
      ''
    end
  end
end
