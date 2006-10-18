require 'test/test_helper'

include Ramaze

class TCSessionController < Template::Ramaze
  def index
    session.inspect
  end

  def set_session key, val
    session[key] = val
    index
  end
end

context "usual Session" do

  start
  Global.mapping['/'] = TCSessionController
  sleep 1

  class Context
    def initialize(url = '/')
      @cookie = open(url).meta['set-cookie']
    end

    def open url, hash = {}
      Kernel.open("http://localhost:#{Global.port}#{url}", hash)
    end

    def request opt
      open(opt, 'Set-Cookie' => @cookie).read
    end

    def erequest opt
      eval(request(opt))
    rescue Object => ex
      puts ex
      {}
    end
  end

  ctx = Context.new

  specify "Should give me the current session" do
    ctx.erequest('/').should_equal({})
  end

  specify "set some session-parameters" do
    ctx.erequest('/set_session/foo/bar').should_equal 'foo' => 'bar'
  end

  specify "inspect session again" do
    ctx.erequest('/').should_equal 'foo' => 'bar'
  end
end
