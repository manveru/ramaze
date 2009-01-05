#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Helper

    # = Helper::Partial
    #
    # === Example Usage
    #
    #   class MyController
    #     def index
    #     end
    #     def list
    #       plain = request['plain']
    #       "Hello World from List!  Plain List == #{plain}"
    #     end
    #   end
    #
    #
    #   <html>
    #     <head><title>Partial Render Index</title></head>
    #     <body>
    #       #{render_partial(Rs(:list), 'plain' => true)}
    #     </body>
    #   </html>
    module Partial
      DEFAULT << self

      module_function

      # Renders a url 'inline'.
      #
      # +url+      normal URL, like you'd use for redirecting.
      # +options+  optional, will be used as request parameters.
      #
      # Issues a mock request to the given +url+ with +options+ turned into
      # query arguments.
      def render_partial(url, options = {})
        uri = URI(url)
        query = options # Innate::Current.request.params.merge(options)
        uri.query = Rack::Utils.build_query(query)

        body = nil

        Innate::Mock.session do |session|
          cookie = Innate::Current.session.cookie
          session.cookie = cookie
          body = session.get(uri.to_s, options).body
        end

        body
      end

      # Render the template file in view_root of the
      # current controller.
      #
      # TODO:
      # * the local variable hack isn't working because innate allocates a new
      #   binding
      #   For now one can simply use instance variables, which I prefer anyway.
      # * Doesn't work for absolute paths, but there are no specs for that yet.
      def render_template(path, variables = {})
        path = path.to_s

        ext = File.extname(path)
        basename = File.basename(path, ext)
        ext = ext[1..-1]

        action = Innate::Current.action.dup
        action.view = action.node.find_view(basename, ext, action.params)
        action.method = action.node.find_method(basename, action.params)
        action.sync_variables(action)
        action.variables.merge!(variables)

=begin
        variables.each do |key, value|
          value = "ObjectSpace._id2ref(#{value.object_id})"
          eval "#{key} = #{value}", action.binding
        end
=end

        action.call
      end

      def render_action method, *params
        render_partial(Rs(method), *params)
      end
    end
  end
end
