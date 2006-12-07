#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCLinkHelperController < Template::Ramaze
  helper :link

  def index
    link self.class
  end

  def index_with_title
    link self.class, :title => 'Foo'
  end
end


ramaze(:mapping => {'/' => TCLinkHelperController}) do
  context "LinkHelper" do
    include Ramaze::LinkHelper

    specify "testrun" do
      get.should == %{<a href="/">index</a>}
      get('/index_with_title').should == %{<a href="/">Foo</a>}
    end

    specify "link" do
      link(:foo).should                         == %{<a href="foo">foo</a>}
      link(:foo, :bar).should                   == %{<a href="foo/bar">bar</a>}
      link(TCLinkHelperController, :bar).should == %{<a href="/bar">bar</a>}
      link('/foo/bar').should                   == %{<a href="/foo/bar">bar</a>}
    end

    specify "R" do
      R(TCLinkHelperController).should == '/'
    end
  end
end
