#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

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

  { :MemoryCache => :memory,
    :YAMLStoreCache => :yaml_store,
    :MemcachedCache => :memcached,
  }.each do |cache, requirement|
    begin
      require "ramaze/cache/#{requirement}"
    rescue LoadError => ex
      puts ex
      next
    end

    context cache.to_s do

      Ramaze::Global.cache = cache
      Thread.main[:session_cache] = nil

      b = Browser.new

      specify "Should give me an empty session" do
        b.eget.should == {}
      end

      specify "set some session-parameters" do
        b.eget('/set_session/foo/bar').should == {'foo' => 'bar'}
      end

      specify "inspect session again" do
        b.eget('/').should == {'foo' => 'bar'}
      end

      specify "change the session" do
        b.eget('/set_session/foo/foobar')['foo'].should == 'foobar'
      end

      specify "inspect the changed session" do
        b.eget('/')['foo'].should == 'foobar'
      end

      specify "now a little bit with POST" do
        b.epost('/post_set_session', 'x' => 'y')['x'].should == 'y'
      end

      specify "snooping a bit around" do
        b.cookie.split('=').size.should == 3
      end
    end
  end
end
