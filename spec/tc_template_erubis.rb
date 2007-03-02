#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

testcase_requires 'erubis'

class TCTemplateErubisController < Ramaze::Controller
  trait :template_root => 'spec/template/erubis/'
  trait :engine => Ramaze::Template::Erubis

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

context "Erubis" do
  ramaze(:mapping => {'/' => TCTemplateErubisController})

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
