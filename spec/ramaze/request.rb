#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCRequestController < Ramaze::Controller
  map '/'
  engine :None

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
    # referencing request.rack_params breaks this test
    # request.params is hacked to return {} on PUT requests
    request.params
    request.body.read
  end

  def get_inspect
    request.params.inspect
  end

  def test_get
    request['foo']
  end

  def test_post
    [ request['foo'],
      request['bar']['1'],
      request['bar']['7'],
    ].inspect
  end

  def test_headers
  end

  def my_ip
    request.remote_addr
  end
end

options = ramaze_options rescue {}
ramaze options.merge(:public_root => 'spec/ramaze/public')

describe "Request" do
  behaves_like 'http'

  describe "POST" do
    behaves_like 'http'

    it "give me the result of request.post?" do
      post("/is_post").body.should == 'true'
    end

    it "give me the result of request.get?" do
      post("/is_get").body.should == 'false'
    end

    # this here has shown some odd errors... keep an eye on it.
    it "give me back what i gave" do
      post("/post_inspect", 'this' => 'post').body.should == {"this" => "post"}.inspect
    end
  end

  describe "PUT" do
    behaves_like 'http'

    it "put a resource" do
      image = 'favicon.ico'
      image_path = File.join('spec', 'ramaze', 'public', image)
      address = "/put_inspect/#{image}"

      file = File.read(image_path)

      response = put(address, :input => file)
      response.body.dump.should == file.dump
    end
  end

  describe "DELETE" do
    behaves_like 'http'

    it "delete a resource" do
      delete('/is_delete').body.should == 'true'
    end
  end

  describe "GET" do
    behaves_like 'http'

    it "give me the result of request.post?" do
      get("/is_post").body.should == 'false'
    end

    it "give me the result of request.get?" do
      get("/is_get").body.should == 'true'
    end

    it "give me back what i gave" do
      params = {'one' => 'two', 'three' => 'four'}
      get("/get_inspect", params).body.should == params.inspect
    end

    it "my ip" do
      get("/my_ip").body.should == '127.0.0.1'
    end

    it "request[key]" do
      get('/test_get', 'foo' => 'bar').body.should == 'bar'
      post('/test_post', 'foo' => 'null', 'bar[1]' => 'eins', 'bar[7]' => 'sieben').body.should ==
        ['null', 'eins', 'sieben'].inspect
    end
  end

  describe "get files" do
    behaves_like 'http'

    it "binary" do
      image_path = '/favicon.ico'
      static_image = File.read("spec/ramaze/public#{image_path}")

      response = get(image_path)
      response.status.should == 200
      response.body.should == static_image
    end

    it 'plain test' do
      css_path = '/test_download.css'
      static_css = File.read("spec/ramaze/public#{css_path}").strip

      response = get(css_path)
      response.status.should == 200
      response.body.strip.should == static_css
    end
  end
end
