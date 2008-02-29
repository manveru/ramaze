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

    def render_template(file, vars = {})
      current = Action.current
      options = { :controller => current.controller,
                  :instance => current.instance.dup }

      roots = [options[:controller].template_root].flatten

      if (files = Dir["{#{roots.join(',')}}"/"{#{file},#{file}.*}"]).any?
        options[:template] = files.first.squeeze '/'
      else
        Inform.warn "render_template: #{file} does not exist in the following directories: #{roots.join(',')}."
        return ''
      end

      binding = options[:instance].scope

      vars.each do |name, value|
        options[:instance].instance_variable_set("@#{name}", value)

        value = "ObjectSpace._id2ref(#{ value.object_id })"
        eval "#{ name } = #{ value }", binding
      end

      options[:binding] = binding

      Ramaze::Action(options).render
    end
  end
end
