#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCCacheHelperController < Ramaze::Controller
  map :/

  helper :cache
  cache :cached_action

  def index
    self.class.name
  end

  def cached_value
    value_cache[:time] ||= random
  end

  def uncache_value
    value_cache.delete :time
  end

  def cached_action
    random
  end

  def uncache_actions
    action_cache.clear
  end

  private

  def random
    [Time.now.usec, rand].inspect
  end
end

describe "CacheHelper" do
  ramaze

  it "testrun" do
    get('/').body.should == 'TCCacheHelperController'
  end

  def cached_value() get('/cached_value').body end
  def uncache_value() get('/uncache_value').body end
  def cached_action() get('/cached_action').body end
  def uncache_actions() get('/uncache_actions').body end

  it "cached value" do
    3.times do
      lambda{ cached_value }.should_not change{ cached_value }
    end

    3.times do
      lambda{ uncache_value }.should change{ cached_value }
    end
  end

  it "cached action" do
    3.times do
      lambda{ cached_action }.should_not change{ cached_action }
    end

    3.times do
      lambda{ uncache_actions }.should change{ cached_action }
    end
  end
end
