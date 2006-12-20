#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

class TCTemplateController < Template::Ramaze
  trait :template_root => 'test/template/ramaze'

  def index text
    @text = text
  end

  def sum num1, num2
    @num1, @num2 = num1.to_i, num2.to_i
  end

  def nested key, value
    @hash = {key => value}
  end

  def internal *args
    @args = args
    '<?r i = 2 ?>#{i * i} #{@args.inspect} on the table'
  end
end


ramaze(:mapping => {'/' => TCTemplateController}) do

  context "Ramaze" do
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
  end
end

__END__
  class OtherController < Template::Ramaze
    def stuff string, vars = {}
      transform(string, vars)
    end
  end

  context "simple internal template" do
    def transform(string, ivs = @ivs)
      OtherController.new.stuff(string, ivs || {})
    end

    specify "hello world" do
      @ivs = {:string => 'World'}
      transform('Hello, #{@string}').should == 'Hello, World'
      transform('Hello, <%= @string %>').should == 'Hello, World'
    end

    specify "plain interpolation" do
      @ivs = {:string => 'World'}
      transform("<%= @string %>").should == 'World'
      transform('#{@string}').should == 'World'
    end

    specify "internal ruby" do
      transform('<% a = 1+1 %> #{a}').should == '2'
      transform('<?r a = 1+1 ?> #{a}').should == '2'
    end
  end
end
