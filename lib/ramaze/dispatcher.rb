require 'timeout'

module Ramaze
  module Dispatcher
    class << self
      def handle orig_request, orig_response
        return create_response(orig_response, orig_request)
      rescue Object => e
        if Global.error_page
          if Error.constants.include?(e.class.name.split('::').last)
            Logger.error e.message
          else
            Logger.error e
          end
          return Error::Response.new(e)
        else
          Logger.error e
          return Response.new('', STATUS_CODE[:internal_error], 'Content-Type' => 'text/html')
        end
      end

      def create_response orig_response, orig_request
        setup_environment orig_response, orig_request
        fill_out
      end

      def fill_out
        path = request.request_path.squeeze('/')
        Ramaze::Logger.debug "Request from #{request.remote_addr}: #{path}"

        the_paths = $:.map{|way| (way/'public'/path) }
        if file = the_paths.find{|way| File.exist?(way) and File.file?(way)}
          response.head['Content-Type'] = ''
          response.out = File.read(file)
        else
          controller, action, params = resolve_controller(path)
          response.out = handle_controller(request, controller, action, params)
          response.head['Set-Cookie'] = session.export
        end
        response
      end

      def resolve_action controller, paraction
        Ramaze::Logger.info :resolve_action, controller, paraction

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
            else
              raise Ramaze::Error::WrongParameterCount
            end
          end
        end
      end

      def resolve_controller path
        Ramaze::Logger.info :resolve_controller, path.inspect
        track = path.split('/')
        controller = false
        action = false
        tracks = []

        track.unshift '/'

        track.each do |atom|
          tracks << (tracks.last.to_s / atom)
        end

        until controller and action or tracks.empty?
          current = tracks.pop
          paraction = path.gsub(/^#{current}/, '').split('/')
          paraction.delete('')
          if controller = Ramaze::Global.mapping[current]
            action, params = resolve_action controller, paraction
          end
        end

        raise Ramaze::Error::NoController, "No Controller found for #{path}" unless controller
        raise Ramaze::Error::NoAction, "No Action found for #{path}" unless action

        return controller, action, params
      end

      def handle_controller request, controller, action, params
        if Ramaze::Global.cache
          Global.out_cache ||= {}

          key = [controller.__id__, action, params]
          out = Global.out_cache[key]

          return out if out

          Ramaze::Logger.debug "Compiling Action: #{action} #{params.join(', ')}"
          Global.out_cache[key] = request_controller request, controller, action, params
        else
          controller.handle_request(request, action, *params)
        end
      end

      def setup_environment orig_response, orig_request
        Thread.current[:response] = Response.new('', STATUS_CODE[:ok], 'Content-Type' => 'text/html')
        Thread.current[:request]  = Request.new(orig_request)
        Thread.current[:session]  = Session.new(request)
      end

      def response
        Thread.current[:response]
      end

      def request
        Thread.current[:request]
      end

      def session
        Thread.current[:session]
      end

    end
  end
end

module Ramaze
  STATUS_CODE = {
    # 1xx Informational (Request received, continuing process.)

    :continue                         => 100,
    :switching_protocols              => 101,

    # 2xx Success (The action was successfully received, understood, and accepted.)

    :ok                               => 200,
    :created                          => 201,
    :accepted                         => 202,
    :non_authorative_information      => 203,
    :no_content                       => 204,
    :resent_content                   => 205,
    :partial_content                  => 206,
    :multi_status                     => 207,

    # 3xx Redirection (The client must take additional action to complete the request.)

    :multiple_choices                 => 300,
    :moved_permamently                => 301,
    :moved_temporarily                => 302,
    :found                            => 302,
    :see_other                        => 303,
    :not_modified                     => 304,
    :use_proxy                        => 305,
    :switch_proxy                     => 306,
    :temporary_redirect               => 307,

    # 4xx Client Error (The request contains bad syntax or cannot be fulfilled.)

    :bad_request                      => 400,
    :unauthorized                     => 401,
    :payment_required                 => 402,
    :forbidden                        => 403,
    :not_found                        => 404,
    :method_not_allowed               => 405,
    :not_aceptable                    => 406,
    :proxy_authentication_required    => 407,
    :request_timeout                  => 408,
    :conflict                         => 409,
    :gone                             => 410,
    :length_required                  => 411,
    :precondition_failed              => 412,
    :request_entity_too_large         => 413,
    :request_uri_too_long             => 414,
    :unsupported_media_type           => 415,
    :requested_range_not_satisfiable  => 416,
    :expectation_failed               => 417,
    :retry_with                       => 449,

    # 5xx Server Error (The server failed to fulfill an apparently valid request.)

    :internal_server_error            => 500,
    :not_implemented                  => 501,
    :bad_gateway                      => 502,
    :service_unavailable              => 503,
    :gateway_timeout                  => 504,
    :http_version_not_supported       => 505,
    :bandwidth_limit_exceeded         => 509, # (not official)
  }
end
