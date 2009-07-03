require "addressable/template"

module Ramaze
  # This is a simple prototype-implementation of how we could do routing
  # supported by URI templates.
  #
  # Please see the spec for example usage as it's not integrated yet in any way.
  #
  # What it does is basically that you can give it any URI template and a final
  # mapping, and it will extract the variables from the URI and merge them into
  # the QUERY_STRING, which is parsed again in Ramaze if you issue
  # Request#params.
  #
  # @example given mapping like:
  #
  #     map('/customer/{customer_id}/order/{order_id}', '/order/show')
  #
  # @example output of request.params at '/order/show'
  #
  #     {'customer_id => '12', 'order_id' => '15'}
  #
  # I haven't explored the full capabilities of the templates yet, but the
  # specs of Addressable::Template suggest that there is a lot to be
  # discovered.
  class AddressableRoute
    def initialize(app, routes = {})
      @app = app
      @routes = {}

      routes.each{|from, to| map(from, to) }
    end

    def call(env)
      path_info = env['PATH_INFO']

      @routes.each do |template, target|
        extracted = template.extract(path_info)
        return dispatch(env, target, extracted) if extracted
      end

      @app.call(env)
    end

    def map(from, to)
      @routes[Addressable::Template.new(from)] = to
    end

    def dispatch(env, target, extracted)
      env['PATH_INFO'] = target
      original = Rack::Utils.parse_query(env['QUERY_STRING'])
      env['QUERY_STRING'] = Rack::Utils.build_query(original.merge(extracted))

      @app.call(env)
    end
  end
end
