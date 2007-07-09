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
      options.keys.each {|x| saved[x] = Request.current.params[x] }
      saved_action = Thread.current[:action]

      Request.current.params.update(options)

      Controller.handle(url)
    ensure
      Thread.current[:action] = saved_action
      options.keys.each {|x| Request.current.params[x] = saved[x] }
    end

    # Generate from a filename in template_root of the given (or current)
    # controller a new action.
    # Any option you don't pass is instead taken from Action.current

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
