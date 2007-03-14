#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

class TCSessionController < Ramaze::Controller
  def index
    session.inspect
  end

  def set_session key, val
    session[key] = val
    index
  end

  def post_set_session
    session.merge! request.params
    index
  end
end

context "Session" do
  ramaze(:mapping => {'/' => TCSessionController})

  ctx = Context.new

  specify "Should give me an empty session" do
    ctx.eget.should == {}
  end

  specify "set some session-parameters" do
    ctx.eget('/set_session/foo/bar').should == {'foo' => 'bar'}
  end

  specify "inspect session again" do
    ctx.eget('/').should == {'foo' => 'bar'}
  end

  specify "change the session" do
    ctx.eget('/set_session/foo/foobar')['foo'].should == 'foobar'
  end

  specify "inspect the changed session" do
    ctx.eget('/')['foo'].should == 'foobar'
  end

  specify "now a little bit with POST" do
    ctx.epost('/post_set_session', 'x' => 'y')['x'].should == 'y'
  end

  specify "snooping a bit around" do
    ctx.cookie.split('=').size.should == 3
  end
end
