#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

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
