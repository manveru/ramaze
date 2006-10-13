module Ramaze
  module Adapter
    module Default
      def handle request
        debug :handle, request
        uri = request.params["REQUEST_URI"]
        # uri = "/templates/test"
        path = uri.split('/')
        # ['', 'home']
        path.shift
        # ['home']
        map = Global.mapping

        handler = map['/']
        unless path.empty?
          # TODO: add right to left handling
          handler = map["/#{path.first}"]
        end
        debug :handler, handler
        debug :handler, handler.class

        action = (path[1] || :index).to_sym
        debug :action, action

        templater = handler.class.send(:send, :class_variable_get, '@@templating') rescue :ramaze
        debug :global_mapping, map
        require "ramaze/template/#{templater}"
        template = "Ramaze::Template::#{templater.to_s.capitalize}"
        debug :search_template, template
        template = constant(template)

        begin
          debug :template, template
          response = template.transform action, handler
        rescue NoActionError => e
          error e
          error e.backtrace
        end

        head_defaults = {
          'Content-Type' => 'text/html'
        }

        response.head = head_defaults.merge(response.head)

        debug :response, response

        response = {
          :head => response.head,
          :out  => response.out
        }
      end
    end
  end
end
