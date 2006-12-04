require 'lib/test/test_helper'

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

ramaze(:mapping => {'/' => TCSessionController}) do
  context "usual Session" do
    class Context
      def initialize(url = '/')
        @cookie = open(url).meta['set-cookie']
      end

      def open url, hash = {}
        Kernel.open("http://localhost:#{Global.port}#{url}", hash)
      end

      def request opt = ''
        open(opt, 'Set-Cookie' => @cookie).read
      end

      def erequest opt = ''
        eval(request(opt))
      rescue Object => ex
        puts ex
        ex
      end
    end

    ctx = Context.new

    specify "Should give me an empty session" do
      ctx.erequest.should == {}
    end

    specify "set some session-parameters" do
      ctx.erequest('/set_session/foo/bar').should == {'foo' => 'bar'}
    end

    specify "inspect session again" do
      ctx.erequest('/').should == {'foo' => 'bar'}
    end

    specify "change the session" do
      ctx.erequest('/set_session/foo/foobar').should == {'foo' => 'foobar'}
    end

    specify "inspect the changed session" do
      ctx.erequest('/').should == {'foo' => 'foobar'}
    end
  end
end
