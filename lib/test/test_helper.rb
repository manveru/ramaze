require 'rubygems'
require 'open-uri'
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

Ramaze::Global.mode = :debug
Ramaze::Global.adpater = :mongrel
Ramaze::Global.run_loose = true
Ramaze::Global.error_page = false
