require 'ramaze'

include Ramaze

class MainController < Controller
  map '/'
  helper :cache
  trait :actions_cached => [:index]

  def index
%[
<html>
  <head><title>examples/caching</title></head>
  <body>
    <p>
      This action just shows you a random number: #{rand * 100}.<br />
      If you <a href="/">refresh</a> the page it won't change since you see a cached version.<br />
      But if you <a href="/invalidate">invalidate</a> it, the page will be regenerated.
    </p>
  </body>
</html>
]
  end

  def invalidate
    action_cache.clear
    redirect :/
  end
end

Ramaze.start
