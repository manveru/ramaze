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

      Request.current.params.update(options)

      Controller.handle(url)
    ensure
      options.keys.each {|x| Request.current.params[x] = saved[x] }
    end

    # Render the template file in template_root of the
    # current controller.

    def render_template(file, locals = {})
      current = Action.current
      options = { :controller => current.controller,
                  :instance => current.instance.dup }

      roots = [options[:controller].template_root].flatten

      if (files = Dir["{#{roots.join(',')}}"/"{#{file},#{file}.*}"]).any?
        options[:template] = files.first
      else
        Inform.warn "render_template: #{filename} does not exist"
        return ''
      end

      # use method_missing to provide access to locals, if any exist
      options[:instance].meta_def(:method_missing) { |sym, *args|
        return locals[sym] if locals.key?(sym)
        super
      } if locals.any?

      options[:binding]  = options[:instance].instance_eval{ binding }

      Ramaze::Action(options).render
    end
  end
end
