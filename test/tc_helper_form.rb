#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

begin
  require 'og'

  class Entry
    attr_accessor :title, String
  end

  Og.start :destroy => true

  include Ramaze

  class TCFormHelperController < Template::Ramaze
    helper :form

    def index
    'FormHelper Index'
    end

    def form_with_submit
      form Entry
    end

    def form_without_submit
      form Entry, :submit => false
    end

    def form_with_title
      form Entry, :title => 'Title'
    end

    def form_without_title
      form Entry, :title => false
    end

    def form_with_oid
      form Entry, :except => nil
    end
  end


  context "FormHelper" do
    ramaze(:mapping => {'/' => TCFormHelperController})

    specify "testrun" do
      get('/').should == 'FormHelper Index'
    end

    specify "with submit" do
      get('/form_with_submit').should ==
      %{title: <input type="text" name="title" value="" /><br />\n<input type="submit" />}
    end

    specify "without submit" do
      get('/form_without_submit').should ==
      %{title: <input type="text" name="title" value="" />}
    end

    specify "with title" do
      get('/form_with_title').should ==
      %{Title: <input type="text" name="title" value="" /><br />\n<input type="submit" />}
    end

    specify "without title" do
      get('/form_without_title').should ==
      %{<input type="text" name="title" value="" /><br />\n<input type="submit" />}
    end

    specify "with oid" do
      get('/form_with_oid').should ==
      %{title: <input type="text" name="title" value="" /><br />\noid: <input type="text" name="oid" value="0" /><br />\n<input type="submit" />}
    end
  end

rescue LoadError
end
