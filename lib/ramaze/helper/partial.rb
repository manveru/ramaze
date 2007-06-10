#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module PartialHelper

    private
    module_function

    # Renders a url 'inline'.
    #
    # url:      normal URL, like you'd use for redirecting.
    # options:  optional, will be used as request parameters.

    def render_partial(url, options = {})
      saved = {}
      options.keys.each {|x| saved[x] = request.params[x] }

      request.params.update(options)

      Controller.handle(url)
    ensure
      options.keys.each {|x| request.params[x] = saved[x] }
    end

    def render_template(file, options = {})
      current = Action.current
      options[:binding]     ||= current.binding
      options[:controller]  ||= current.controller
      options[:instance]    ||= current.instance
      options[:template] = (options[:controller].template_root/file)

      action = Ramaze::Action(options)
      action.render
    end
  end
end
