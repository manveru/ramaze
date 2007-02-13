#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), '..', 'lib')

require 'ramaze'

begin
  require 'rubygems'
rescue LoadError => ex
end

require 'spec'

require 'timeout'
require 'open-uri'
require 'net/http'

# provides get/post methods for use inside your
# Spec::Runner

module StatelessContext
  def raw_get url = ''
    url = "http://localhost:#{Ramaze::Global.port}" + "/#{url}".squeeze('/')
    Timeout.timeout(1) do
      open(url)
    end
  rescue Timeout::Error => ex
    ex
  end

  # just GET an [url]

  def get url = ''
    raw_get(url).read.strip
  end

  # POST to an url the given params

  def post url = '', params = {}
    url = "http://localhost:#{Ramaze::Global.port}" + "/#{url}".squeeze('/')
    uri = URI.parse(url)
    Timeout.timeout(1) do
      res = Net::HTTP.post_form(uri, params)
      result = res.body.to_s.strip
      #p res => result
      result
    end
  rescue Timeout::Error => ex
    ex
  end
end

include StatelessContext

# provides a convinient Context for your requests
# so you can simulate sessions and consecutive requests

class Context
  attr_accessor :cookie

  # initialize the context with an url to obtain your cookie

  def initialize(url = '/', base = nil)
    @base = base
    @cookie_url = with_base(url)
    @history = []
    reset
  end

  # combines the url given with the @base given, sanitizes
  # the result a bit.

  def with_base(url = '/')
    url = url.to_s.squeeze('/')
    if @base
      unless url[0...@base.size] == @base
        url = [@base,  url].join('/')
      end
    end
    url.strip.squeeze('/')
  end

  # reset your session

  def reset(url = @cookie_url)
    @cookie = obtain_cookie( with_base(url) )
  end

  # just get a cookie, doesn't reset your session

  def obtain_cookie(url = @cookie_url)
    open(url).meta['set-cookie']
  end

  # our custom little open, take into account parameters and
  # the port the server is running on
  # the parameters are used for the session but could use
  # any headers you wanna use for the request

  def open url, hash = {}
    unless @history.empty?
      hash = {'HTTP_REFERER' => @history.last}.merge(hash)
    end
    url = with_base(url)
    uri = "http://localhost:#{Global.port}#{url}"
    puts "GET: #{uri}"
    result = Kernel.open(uri, hash)
    @history << url
    result
  end

  # use Context#open with our cookie
  # you can pass any header you want with an hash

  def get url = '', headers = {}
    open(url, {'Set-Cookie' => @cookie}.merge(headers)).read
  end

  # Net::HTTP.post_form with the cookie
  # params are for the POST-parameters

  def post url_param = '', params = {}, limit = 10
    raise "Too many redirections" if limit <= 0

    params['Set-Cookie'] = @cookie
    url = "http://localhost:#{Ramaze::Global.port}"
    new = with_base("/#{url_param.gsub(url, '')}")
    url << new

    uri = URI.parse(url)
    puts "POST: #{uri}"
    res = Net::HTTP.post_form(uri, params)
    @history << uri.path

    case res
    when Net::HTTPSuccess
      result = res.body.to_s.strip
      result
    when Net::HTTPRedirection
      post(res['location'], params, limit - 1)
    else
      res.error!
    end
  end

  # like post, but seval the returned string
  # very comfortable if you just do {'foo' => 'bar'}.inspect in your template
  # and in your specs you can
  # epost('/foo').should == {'foo' => 'bar'}

  def epost opt = '', params = {}
    seval(post(opt, params))
  end

  # like get, but seval the returned string
  # very comfortable if you just do {'foo' => 'bar'}.inspect in your template
  # and in your specs you can
  # eget('/foo').should == {'foo' => 'bar'}

  def eget opt = ''
    seval(get(opt))
  end

  # a very simple wrapper for eval that returns the
  # error-message instead of the result of the eval
  # in case there are errors.

  def seval(string)
    eval(string)
  rescue Object => ex
    ex.message
  end
end

module Spec::Runner::ContextEval::ModuleMethods

  # start up ramaze with a given hash of options
  # that will be merged with the default-options.

  def ramaze_start hash = {}
    options = {
      :mode         => :debug,
      :adapter      => :webrick,
      :run_loose    => true,
      :error_page   => false,
      :port         => 7007,
      :host         => '127.0.0.1',
      :force        => true,
      :force_setup  => true,
    }.merge(hash)

    Ramaze.start(options)
  end

  alias ramaze ramaze_start

  # shutdown ramaze, this is not implemeted yet
  # (and might never be due to limited possibilites)

  def ramaze_teardown
    #Ramaze.teardown
  end
end


# require each of the following and rescue LoadError, telling you why it failed.

def testcase_requires(*following)
  following.each do |file|
    require(file.to_s)
  end
rescue LoadError => ex
  puts ex
  puts "Can't run #{$0}: #{ex}"
  puts "Usually you should not worry about this failure, just install the"
  puts "library and try again (if you want to use that feature later on)"
  exit
end
