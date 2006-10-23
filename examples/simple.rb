require 'ramaze'

include Ramaze

class SimpleController < Template::Ramaze
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

Global.adapter    = :webrick
Global.mode       = :debug
Global.run_loose  = true
Global.caching    = false
Global.mapping    = {
  '/' => SimpleController
}

start

require 'open-uri'

%w[ / /simple /post_or_get].each do |action|
  puts "requesting #{action}"
  puts open("http://localhost:7000#{action}").read
end
