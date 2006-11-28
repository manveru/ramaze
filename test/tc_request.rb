require 'ramaze'
require 'test/test_helper'

require 'net/http'
require 'open-uri'
require 'uri'

include Ramaze

class TCRequestController < Template::Ramaze
  def is_post
    request.post?.to_s
  end

  def is_get
    request.get?.to_s
  end

  def post_inspect
    request.params.inspect
  end

  def get_inspect
    request.params.inspect
  end

  def my_ip
    request.remote_addr
  end
end

context "POST" do

  #Global.adapter = :mongrel
  start
  Global.mapping['/'] = TCRequestController

  specify "give me the result of request.post?" do
    post("is_post").should == 'true'
  end

  specify "give me the result of request.get?" do
    post("is_get").should == 'false'
  end

  specify "give me back what i gave" do
    eval(post("post_inspect", 'this' => 'post')).should == {"this" => "post"}
  end
end

context "GET" do

  Global.adapter = :mongrel
  start
  Global.mapping['/'] = TCRequestController

  specify "give me the result of request.post?" do
    get("/is_post").should == 'false'
  end

  specify "give me the result of request.get?" do
    get("/is_get").should == 'true'
  end

  specify "give me back what i gave" do
    eval(get("/get_inspect?one=two&three=four")).should == {'one' => 'two', 'three' => 'four'}
  end

  specify "my ip" do
    get("/my_ip").should == '127.0.0.1'
  end
end
