#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # = PartialHelper
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

  module PartialHelper

    private
    module_function

    # Renders a url 'inline'.
    #
    # url:      normal URL, like you'd use for redirecting.
    # options:  optional, will be used as request parameters.

    def render_partial(url, options = {})
      saved = {}
      options.keys.each {|x| saved[x] = Request.current.params[x] }
      saved_action = Action.current

      Request.current.params.update(options)

      Controller.handle(url)
    ensure
      Thread.current[:action] = saved_action
      options.keys.each {|x| Request.current.params[x] = saved[x] }
    end

    # Render the template file in template_root of the
    # current controller.

    def render_template(file, locals = {})
      current = Action.current

      options = { :controller => current.controller,
                  :instance => current.instance.dup }

      options[:template] = options[:controller].template_root/file
      options[:binding]  = options[:instance].instance_eval{ binding }

      # use method_missing to provide access to locals, if any exist
      options[:instance].instance_eval {
        @__locals = locals
        def method_missing sym, *args, &block
          return @__locals[sym] if @__locals.key?(sym)
          super
        end
      } if locals.any?

      action = Ramaze::Action(options)
      action.render
    ensure
      Thread.current[:action] = current
    end
  end
end
