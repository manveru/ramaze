require 'lib/test/test_helper'

include Ramaze

class MainController < Template::Ramaze
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

class MinorController < Template::Ramaze
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

ramaze do
  context "default Helper" do
    
    def lh
      @lh ||= Class.new.extend(Ramaze::LinkHelper)
    end

    specify "testrun" do
      get('/index').should == 'MainController'
      get('/minor').should == 'MinorController'
    end

    specify "RedirectHelper" do
      get('/redirection').should       == 'MainController target'
      get('/minor/redirection').should == 'MinorController target'
      get('/double_redirection').should       == 'MainController target'
      get('/minor/double_redirection').should == 'MinorController target'
    end

    specify "LinkHelper" do
      lh.link(:foo).should == %{<a href="foo">foo</a>}
      lh.link(:foo, :bar).should == %{<a href="foo/bar">bar</a>}
      lh.link(MinorController, :bar).should == %{<a href="/minor/bar">bar</a>}
      lh.link(MainController, :bar).should == %{<a href="/bar">bar</a>}
      lh.link('/foo/bar').should == %{<a href="/foo/bar">bar</a>}
    end

    specify "RedirectHelper and LinkHelper combined" do
      get(lh.link_raw(MainController, :link_redirection)).should == "MainController"
    end

  end
end
