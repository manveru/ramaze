module Ramaze
  module PartialHelper

    private

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

    module_function :render_partial
  end

end
