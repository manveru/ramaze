#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCTemplateErubisController < Template::Erubis
  trait :template_root => 'test/template/erubis/'

  def index
    'Erubis Index'
  end

  def sum num1, num2
    @num1, @num2 = num1.to_i, num2.to_i
  end

  def inline *args
    @args = args
    "<%= @args.inspect %>"
  end
end

ramaze(:mapping => {'/' => TCTemplateErubisController}) do
  context "Erubis" do
    specify "index" do
      get('/').should == 'Erubis Index'
    end

    specify "sum" do
      get('/sum/1/2').should == '3'
    end

    specify "inline" do
      get('/inline/foo/bar').should == %w[foo bar].inspect
    end
  end
end
