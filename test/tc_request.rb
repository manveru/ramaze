require 'ramaze'
require 'test/test_helper'

require 'net/http'
require 'open-uri'
require 'uri'

include Ramaze

class TCRequestController < Template::Ramaze
  def is_post
    request.post?
  end

  def is_get
    request.get?
  end

  def post_inspect
    request.post_query.inspect
  end

  def get_inspect
    request.get_query.inspect
  end

  def my_ip
    request.remote_addr
  end
end

context "POST" do

  start
  Global.mapping['/'] = TCRequestController

  def request req, params = {}
    uri = URI.parse("http://localhost:7000#{req}")
    res = Net::HTTP.post_form(uri, params)
    res.body
  end

  specify "give me the result of request.post?" do
    request("/is_post").should_equal 'true'
  end

  specify "give me the result of request.get?" do
    request("/is_get").should_equal 'false'
  end

  specify "give me back what i gave" do
    eval(request("/post_inspect", 'this' => 'post')).should_equal "this" => "post"
  end
end

context "GET" do

  start
  Global.mapping['/'] = TCRequestController

  def request req, params = {}
    open("http://localhost:#{Ramaze::Global.port}#{req}").read
  end

  specify "give me the result of request.post?" do
    request("/is_post").should_equal 'false'
  end

  specify "give me the result of request.get?" do
    request("/is_get").should_equal 'true'
  end

  specify "give me back what i gave" do
    eval(request("/get_inspect?one=two&three=four")).should_equal 'one' => 'two', 'three' => 'four'
  end

  specify "my ip" do
    request("/my_ip").should_equal '127.0.0.1'
  end
end
