require 'open-uri'
require 'net/http'

require 'rubygems'
require 'spec'
$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), '..', 'lib')
require 'ramaze'

def get url = ''
  url = "http://localhost:#{Ramaze::Global.port}" + "/#{url}".gsub(/^\/+/, '/')
  result = open(url).read.strip
  #p url => result
  result
end

def post url = '', params = {}
  url = "http://localhost:#{Ramaze::Global.port}" + "/#{url}".gsub(/^\/+/, '/')
  uri = URI.parse(url)
  res = Net::HTTP.post_form(uri, params)
  result = res.body.to_s.strip
  #p res => result
  result
end

def ramaze_start hash = {}
  options = {
    :mode       => :silent,
    :adapter    => :mongrel,
    :run_loose  => true,
    :error_page => false,
  }
  Ramaze.start(options.merge(hash))
end

def ramaze_teardown
end

def ramaze(hash = {})
  ramaze_start(hash)
  yield if block_given?
  ramaze_teardown
end
