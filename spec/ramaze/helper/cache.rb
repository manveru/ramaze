#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class SpecHelperCache < Ramaze::Controller
  map '/'
  helper :cache
  cache_action :method => :cached_action

  def cached_value
    cache_value[:time] ||= random
  end

  def cached_action
    random
  end

  private

  def random
    [Time.now.usec, rand].inspect
  end
end

class SpecHelperCacheTTL < Ramaze::Controller
  map '/ttl'

  helper :cache
  cache_action(:method => :index, :ttl => 1)

  def index
    rand
  end
end

class SpecHelperCacheKey < Ramaze::Controller
  map '/key'

  helper :cache
  cache_action(:method => :name){ request[:name] }

  def name
    "hi #{request['name']} #{rand}"
  end
end

describe Ramaze::Helper::Cache do
  behaves_like :mock

  it 'caches actions' do
    got = get('/cached_action')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should.not.be.empty

    cached_body = got.body

    got = get('/cached_action')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should == cached_body
  end

  it 'caches values' do
    got = get('/cached_value')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should.not.be.empty

    cached_body = got.body

    got = get('/cached_value')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should == cached_body
  end

  it 'caches actions with ttl' do
    2.times do
      lambda{ get('/ttl').body }.should.not.change{ get('/ttl').body }
    end

    lambda{ sleep 1; get('/ttl').body }.should.change{ get('/ttl').body }
  end
end
