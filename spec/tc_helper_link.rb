#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCLinkHelperController < Template::Ramaze
  helper :link

  def index
    link self
  end

  def index_with_title
    link self, :title => 'Foo'
  end
end


context "LinkHelper" do
  ramaze(:mapping => {'/' => TCLinkHelperController})

  include Ramaze::LinkHelper

  this = TCLinkHelperController

  specify "testrun" do
    get.should == %{<a href="/">index</a>}
    get('/index_with_title').should == %{<a href="/">Foo</a>}
  end

  specify "link" do
    link(:foo).should       == %{<a href="foo">foo</a>}
    link(:foo, :bar).should == %{<a href="foo/bar">bar</a>}
    link(this, :bar).should == %{<a href="/bar">bar</a>}
    link('/foo/bar').should == %{<a href="/foo/bar">bar</a>}
  end

  specify "link with title" do
    link(:foo, :title => 'bar').should == %{<a href="foo">bar</a>}
  end

  specify "link with get-parameters" do
    link(:foo, :first => :bar, :title => 'bar').should == %{<a href="foo?first=bar">bar</a>}
    l = link(:foo, :first => :bar, :second => :foobar)
    m = l.match(%r{<a href="foo\?(.*?)=(.*?);(.*?)=(.*?)">(.*?)</a>}).to_a
    m.shift
    m.pop.should == 'foo'
    Hash[*m].should == {'first' => 'bar', 'second' => 'foobar'}
  end

  specify "R" do
    R(this).should == '/'
    R(this, :foo).should == '/foo'
    R(this, :foo, :bar => :one).should == '/foo?bar=one'
  end
end
