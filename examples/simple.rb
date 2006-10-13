require 'ramaze'

include Ramaze

class SimpleController
  def index
    "simple"
  end

  def simple
    request.inspect
  end

  def post_or_get
    request.post? ? 'POST' : 'GET'
  end
end

Global.mode = :debug
Global.port = 7000
Global.run_loose = true
Global.caching = false
Global.mapping = {
  '/' => SimpleController
}

start
sleep 0.5

require 'open-uri'

%w[ / /simple /post_or_get].each do |action|
  puts open("http://localhost:7000#{action}").read
end
