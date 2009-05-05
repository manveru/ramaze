require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  map '/'
  helper :cache

  def index
    @number = rand * 100

%q[
<html>
  <head><title>examples/caching</title></head>
  <body>
    <p>
      This action just shows you a random number: #{@number}.<br />
      If you <a href="/">refresh</a> the page it won't change since you see a cached version.<br />
      But if you <a href="/invalidate">invalidate</a> it, the page will be regenerated.
    </p>
  </body>
</html>
]
  end

  cache_action :method => 'index'

  def invalidate
    Ramaze::Cache.action.delete('/')
    redirect :/
  end
end

Ramaze.start
