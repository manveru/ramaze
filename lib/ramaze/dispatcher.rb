#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'
require 'ramaze/tool/mime'

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
    trait :filters => [
            lambda{|path| handle_action path },
            lambda{|path| handle_file   path },
          ]
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
        error exception
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

            unless ((req.request_uri.path = '/error') rescue false)
              req.request.params['REQUEST_PATH'] = '/error'
            end

            handle_response
          else
            build_response(exception.message, STATUS_CODE[:internal_server_error])
          end
        end
      end

      # setup the #setup_environment (Trinity) and start #handle_response
      #
      # Obtain the path requested from the request and search for a static
      # file matching the request, #respond_file is called if it finds one,
      # otherwise the path is given on to #respond_action.
      # Answers with a response

      def respond orig_response, orig_request
        setup_environment orig_response, orig_request
        handle_response
      end

      def handle_response
        path = request.request_path.squeeze('/')
        info "Request from #{request.remote_addr}: #{path}"

        catch :respond do
          filtered = filter(path)

          if filtered.is_a?(Exception)
            error filtered
            return(handle_error(filtered))
          else
            return(build_response filtered, 200)
          end
        end
      end

      def filter path
        gotchas = ancestral_trait[:filters].map{|f| f[path] }.flatten.compact

        exceptions, non_exceptions = gotchas.partition{|g| g.is_a?(Exception)}

        possible = [non_exceptions, exceptions].compact.flatten
        possible.first
      end

      def handle_action path
        handler = Controller.handle(path)
      rescue => ex
        ex
      end

      def handle_file path
        custom_publics = Global.controllers.map{|c| c.trait[:public]}.compact
        the_paths = $:.map{|way| (way/'public'/path) }
        the_paths += custom_publics.map{|c| c/path   }
        file = the_paths.find{|way| File.file?(way)}

        if file
          response.head['Content-Type'] = Tool::MIME.type_for(file)
          File.open(file)
        end
      end

      # takes the content, code and head for a new response, will set the cookies
      # if Global.cookies is true (which it is by default) and set the default
      # Content-Type to 'text/plain'

      def build_response out = '', code = STATUS_CODE[:internal_server_error], head = nil
        default_head = {
          'Content-Type' => 'text/html',
        }

        if Global.cookies
          default_head['Set-Cookie'] = session.export
        else
          head.delete('Set-Cookie')
        end

        head = default_head.merge(head || response.head)

        response.out, response.code, response.head = out, code, head
        response
      end


      # Setup the Trinity (Request, Response, Session) and store them as
      # thread-variables in Thread.current
      #   Thread.current[:request]  == Request.current
      #   Thread.current[:response] == Response.current
      #   Thread.current[:session]  == Session.current

      def setup_environment orig_response, orig_request
        this = Thread.current
        this[:request]  = Request.new(orig_request)
        this[:session]  = Session.new(request)
        this[:response] = Response.new('', STATUS_CODE[:ok], 'Content-Type' => 'text/html')
      end
    end
  end
end
