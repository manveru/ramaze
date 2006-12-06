#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'
require 'open-uri'
require 'net/http'

require 'rubygems'
require 'spec'

$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), '..')
require 'ramaze'

def get url = ''
    url = "http://localhost:#{Ramaze::Global.port}" + "/#{url}".gsub(/^\/+/, '/')
  Timeout.timeout(1) do
    result = open(url).read.strip
    #p url => result
    result
  end
end

def post url = '', params = {}
    url = "http://localhost:#{Ramaze::Global.port}" + "/#{url}".gsub(/^\/+/, '/')
    uri = URI.parse(url)
  Timeout.timeout(1) do
    res = Net::HTTP.post_form(uri, params)
    result = res.body.to_s.strip
    #p res => result
    result
  end
end

def ramaze_start hash = {}
  options = {
    :mode       => :debug,
    :adapter    => :webrick,
    :run_loose  => true,
    :error_page => false,
  }
  Ramaze.start(options.merge(hash))
end

def ramaze_teardown
end

def ramaze(hash = {})
  ramaze_start(hash)
  Timeout.timeout(10) do
    yield if block_given?
  end
  ramaze_teardown
end
