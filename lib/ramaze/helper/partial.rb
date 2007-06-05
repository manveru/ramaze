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
      options = {
        :controller => self,
        :template_root => self.class.template_root
      }.merge(options)
      options[:template] ||= (options[:template_root]/file)
      self.class.render(options)
    end
  end
end
