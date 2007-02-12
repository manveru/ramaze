#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCCacheHelperController < Controller
  helper :cache

  def index
    self.class.name
  end

  def cached_value
    value_cache[:time] ||= random
  end

  def uncache_value
    value_cache.delete(:time)
  end

  def cached_action
    random
  end

  def uncache_actions
    uncache_all
  end

  cache_actions :cached_action

  private

  def random
    [Time.now.usec, rand].inspect
  end
end

context "CacheHelper" do
  ramaze(:adapter => :mongrel, :mapping => {'/' => TCCacheHelperController})

  specify "testrun" do
    get('/').should == 'TCCacheHelperController'
  end

  def cached_value() get('/cached_value') end
  def uncache_value() get('/uncache_value') end
  def cached_action() get('/cached_action') end
  def uncache_actions() get('/uncache_actions') end

  specify "cached value" do
    uncached  = cached_value

    3.times do
      uncached.should == cached_value
    end

    old = cached_value

    3.times do
      uncache_value
      cached_value.should_not == old
    end
  end

  specify "cached action" do
    uncached = cached_action

    3.times do
      cached_action.should == uncached
    end

    old = cached_action

    3.times do
      uncache_actions
      cached_action.should_not == old
    end
  end
end
