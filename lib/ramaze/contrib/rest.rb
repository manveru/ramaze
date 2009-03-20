# Use this together with the Rack::MethodOverride middleware for best
# behaviour.
#
# See spec/contrib/rest.rb for usage.

module Ramaze
  # Don't use one option per method, we don't want to turn request_method into
  # a symbol, together with MethodOverride this could lead to a memory leak.
  options.o "REST rewrite mapping",
    :rest_rewrite, { 'GET'    => 'show',
                     'POST'   => 'create',
                     'PUT'    => 'update',
                     'DELETE' => 'destroy'}

  Rewrite['REST dispatch'] = lambda{|path, request|
    if suffix = Ramaze.options[:rest_rewrite][request.request_method]
      "#{path}/#{suffix}".squeeze('/')
    else
      path
    end
  }
end
