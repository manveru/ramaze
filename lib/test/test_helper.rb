#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'timeout'
require 'open-uri'
require 'net/http'

require 'rubygems'
require 'spec'

$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), '..')
require 'ramaze'

class Context
  def initialize(url = '/')
    @cookie = open(url).meta['set-cookie']
  end

  def open url, hash = {}
    Kernel.open("http://localhost:#{Global.port}#{url}", hash)
  end

  def get url = ''
    open(url, 'Set-Cookie' => @cookie).read
  end

  def post url = '', params = {}
    url = "http://localhost:#{Ramaze::Global.port}" + "/#{url}".gsub(/^\/+/, '/')
    uri = URI.parse(url)
    params['Set-Cookie'] = @cookie
    res = Net::HTTP.post_form(uri, params)
    result = res.body.to_s.strip
    #p res => result
    result
  end

  def epost opt = '', params = {}
    seval(post(opt, params))
  end

  def eget opt = ''
    seval(get(opt))
  end

  def seval(string)
    eval(string)
  rescue Object => ex
    ex.message
  end
end

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

  options.merge(hash).each do |key, value|
    Global[key] = value
  end
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
