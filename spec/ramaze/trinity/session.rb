#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TrinitySessionController < Ramaze::Controller
  map :/

  def index
    "nothing"
  end
end

describe "Session" do
  behaves_like 'http'
  ramaze :sessions => false

  it 'should work without sessions' do
    class Ramaze::Session
      remove_const :IP_COUNT_LIMIT
      const_set(:IP_COUNT_LIMIT, 2)
    end
    (Ramaze::Session::IP_COUNT_LIMIT + 2).times do
      r = get('/')
      r.body.should == "nothing"
      r.headers.should == {'Content-Type' => 'text/html'}
    end
  end
end
