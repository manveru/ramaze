#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

begin
  require 'og'
  require 'glue/timestamped'

  class Entry
    attr_accessor :title, String
  end

  class EntryTimestamped
    attr_accessor :title, String
    is Timestamped
  end

  Og.start :destroy => true

  include Ramaze

  class TCFormHelperEntryController < Template::Ramaze
    helper :form

    def index
      'FormHelper Entry'
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

  class TCFormHelperEntryTimestampedController < Template::Ramaze
    helper :form

    def index
      "FormHelper EntryTimestamped"
    end

    def form_with_submit
      form EntryTimestamped
    end
  end

  context "FormHelper" do
    ramaze

    context "Entry" do
      Global.mapping['/entry'] = TCFormHelperEntryController

      specify "testrun" do
        get('/entry/').should == 'FormHelper Entry'
      end

      specify "with submit" do
        get('/entry/form_with_submit').should ==
          %{title: <input type="text" name="title" value="" /><br />\n<input type="submit" />}
      end

      specify "without submit" do
        get('/entry/form_without_submit').should ==
          %{title: <input type="text" name="title" value="" />}
      end

      specify "with title" do
        get('/entry/form_with_title').should ==
          %{Title: <input type="text" name="title" value="" /><br />\n<input type="submit" />}
      end

      specify "without title" do
        get('/entry/form_without_title').should ==
          %{<input type="text" name="title" value="" /><br />\n<input type="submit" />}
      end

      specify "with oid" do
        get('/entry/form_with_oid').should ==
          %{title: <input type="text" name="title" value="" /><br />\noid: <input type="text" name="oid" value="0" /><br />\n<input type="submit" />}
      end

      context "EntryTimestamped" do
        Global.mapping['/entry_timestamped'] = TCFormHelperEntryTimestampedController

        specify "testrun" do
          get('/entry_timestamped/').should == "FormHelper EntryTimestamped"
        end

        specify "with submit" do
          get('/entry_timestamped/form_with_submit').should ==
            ''
        end
      end
    end
  end

rescue LoadError
end
