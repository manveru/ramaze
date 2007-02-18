#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCRequestController < Controller
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

  def test_headers
  end

  def my_ip
    request.remote_addr
  end
end

context "Request" do
  ramaze ramaze_options.merge( :mapping => {'/' => TCRequestController})

  context "POST" do
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
      image = 'favicon.ico'
      image_path = File.join('spec', 'public', image)
      address = "http://localhost:7007/put_inspect/#{image}"
      response = `curl -S -s -T #{image_path} #{address}`
      file = File.read(image_path)

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

    specify "header" do
      code, status = raw_get('/test_headers').status
      code.to_i.should == 200
      status.strip.should == 'OK'
      raw_get('/test_headers').content_type.should == "text/html"
    end
  end

  context "send_file" do
    specify "send_file" do
      css_path = 'test_download.css'
      image_path = 'favicon.ico'
      static_css = File.read("spec/public/#{css_path}")
      static_image = File.read("spec/public/#{image_path}")

      images = []
      csses = []
      threads = []

      times = 1

      times.times do
        threads << Thread.new do
          csses   << open("http://localhost:#{Global.port}/#{css_path}").read
          images  << open("http://localhost:#{Global.port}/#{image_path}").read
        end
      end

      threads.each do |t|
        t.join
      end

      images.each do |image|
        image.should == static_image
      end

      csses.each do |css|
        css.should == static_css
      end
    end
  end
end
