#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

class TCTemplateController < Ramaze::Controller
  trait :template_root => 'spec/ramaze/template/ezamar'
  trait :engine => Ramaze::Template::Ezamar

  def index text
    @text = text
  end

  def sum num1, num2
    @num1, @num2 = num1.to_i, num2.to_i
  end

  def nested key, value
    instance_variable_set("@#{key}", value)
  end

  def internal *args
    @args = args
    '<?r i = 2 ?>#{i * i} #{@args.inspect} on the table'
  end

  def combined
    @a = 'boo'
    nil
  end
end


context "Ezamar" do
  ramaze(:mapping => {'/' => TCTemplateController})

  specify "hello world" do
    get('/World').should == 'Hello, World!'
    get('/You').should == 'Hello, You!'
  end

  specify "summing" do
    get('/sum/1/2').should == '3'
  end

  specify "nasty nested stuff" do
    get('/nested/foo/bar').should == 'bar'
  end

  specify "template inside controller" do
    get('/internal').should == '4 [] on the table'
    get('/internal/foo').should == '4 ["foo"] on the table'
  end

  specify "without method" do
    get('/file_only').should == "This is only the file"
  end

  specify "combined" do
    100.times do
      get('/combined').should == 'boo'
    end
  end
end
