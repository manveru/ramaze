#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'ramaze/helper/link'

class TCLink < Ramaze::Controller
  map '/'
end

describe "A" do
  include Ramaze::LinkHelper

  it 'should build links' do
    A('title', :href => '/').should == %(<a href="/">title</a>)
    A('title', :href => '/foo').should == %(<a href="/foo">title</a>)

    a = A('title', :href => '/foo', :class => :none)
    a.should =~ /class="none"/
    a.should =~ /href="\/foo"/
  end
end

describe 'R' do
  include Ramaze::LinkHelper

  it 'should build urls' do
    R(TCLink).should == '/'
    R(TCLink, :foo).should == '/foo'
    R(TCLink, :foo, :bar).should == '/foo/bar'
    R(TCLink, :foo, :bar => :baz).should == '/foo?bar=baz'
  end
end
