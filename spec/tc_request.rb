#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCRequestController < Template::Ramaze
  trait :public => 'spec/public'

  def is_post()   request.post?.to_s end
  def is_get()    request.get?.to_s end
  def is_put()    request.put?.to_s end
  def is_delete() request.delete?.to_s end

  def request_inspect
    request.params.inspect
  end

  def post_inspect
    request.params.inspect
  end

  def put_inspect(file)
    request.body.read.inspect
  end

  def get_inspect
    request.params.inspect
  end

  def test_get
    request['foo']
  end

  def test_get_set(arg)
    request['foo'] = arg
    request['foo']
  end

  def test_headers
  end

  def my_ip
    request.remote_addr
  end
end

context "Request" do
  context "POST" do
    ramaze( :adapter => :mongrel, :mapping => {'/' => TCRequestController} )

    specify "give me the result of request.post?" do
      post("is_post").should == 'true'
    end

    specify "give me the result of request.get?" do
      post("is_get").should == 'false'
    end

    # this here has shown some odd errors... keep an eye on it.
    specify "give me back what i gave" do
      post("post_inspect", 'this' => 'post').should == {"this" => "post"}.inspect
    end
  end

  context "PUT" do
    specify "put a ressource" do
      address = "http://localhost:7007/put_inspect/#{CGI.escape(__FILE__)}"
      response = `curl -S -s -T #{__FILE__} #{address}`
      file = File.read(__FILE__)

      response[1..-2].should == file
    end
  end

  context "DELETE" do
    specify "delete a ressource" do
      # find a way to test this one, even curl doesn't support it
    end
  end

  context "GET" do
    specify "give me the result of request.post?" do
      get("/is_post").should == 'false'
    end

    specify "give me the result of request.get?" do
      get("/is_get").should == 'true'
    end

    specify "give me back what i gave" do
      get("/get_inspect?one=two&three=four").should == {'one' => 'two', 'three' => 'four'}.inspect
    end

    specify "my ip" do
      get("/my_ip").should == '127.0.0.1'
    end

    specify "request[key]" do
      get('test_get?foo=bar').should == 'bar'
    end

    specify "request[key] = value" do
      get('test_get_set/bar').should == 'bar'
    end

    specify "header" do
      raw_get('/test_headers').status.should == %w[200 OK]
      raw_get('/test_headers').content_type.should == "text/html"
    end

    specify "send_file" do
      get('test_download.css').should == File.read('spec/public/test_download.css').strip
    end
  end
end
