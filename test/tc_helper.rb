#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCHelperMainController < Template::Ramaze
  def index
    self.class.name
  end

  def redirection
    redirect :target
  end

  def double_redirection
    redirect :redirection
  end

  def link_redirection
    redirect link_raw(self.class)
  end

  def target
    "#{self.class.name} target"
  end
end

class TCHelperMinorController < Template::Ramaze
  def index
    self.class.name
  end

  def redirection
    redirect :target
  end

  def double_redirection
    redirect :redirection
  end

  def link_redirection
    redirect link_raw(self.class)
  end

  def target
    "#{self.class.name} target"
  end
end

ramaze(:mapping => {'/' => TCHelperMainController, '/minor' => TCHelperMinorController}) do
  context "default Helper" do
    
    def lh
      @lh ||= Class.new.extend(Ramaze::LinkHelper)
    end

    specify "testrun" do
      get('/').should      == "TCHelperMainController"
      get('/minor').should == "TCHelperMinorController"
    end

    specify "RedirectHelper" do
      get('/redirection').should              == "TCHelperMainController target"
      get('/double_redirection').should       == "TCHelperMainController target"
      get('/minor/redirection').should        == "TCHelperMinorController target"
      get('/minor/double_redirection').should == "TCHelperMinorController target"
    end

    specify "LinkHelper" do
      lh.link(:foo).should == %{<a href="foo">foo</a>}
      lh.link(:foo, :bar).should == %{<a href="foo/bar">bar</a>}
      lh.link(TCHelperMinorController, :bar).should == %{<a href="/minor/bar">bar</a>}
      lh.link(TCHelperMainController, :bar).should == %{<a href="/bar">bar</a>}
      lh.link('/foo/bar').should == %{<a href="/foo/bar">bar</a>}
    end

    specify "RedirectHelper and LinkHelper combined" do
      get(lh.link_raw(TCHelperMainController, :link_redirection)).should == "TCHelperMainController"
    end

  end
end
