#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'lib/test/test_helper'

include Ramaze

begin
  require 'hpricot'

class TCMorpherController < Template::Ramaze
  def index
    self.class.name
  end

  def simple_if(arg = nil)
    @arg = arg
    %q{
      <p if="@arg.nil?">orig</p>
      <p if="@arg">#{@arg}</p>
    }.strip
  end

  def simple_unless(arg = nil)
    @arg = arg
    %q{
      <p unless="@arg">orig</p>
      <p unless="@arg.nil?">#{@arg}</p>
    }.strip
  end

  def simple_for n = 1
    @n = (0..n.to_i)
    %q{
      <div for="i in @n">#{i}</div>
    }
  end
end

context "Morpher" do
  ramaze :mapping => {'/' => TCMorpherController}

  specify "testrun" do
    get('/').should == 'TCMorpherController'
  end

  specify "if" do
    get('/simple_if').should == '<p>orig</p>'
    get('/simple_if/bar').should == '<p>bar</p>'
  end

  specify "unless" do
    get('/simple_unless').should == '<p>orig</p>'
    get('/simple_unless/bar').should == '<p>bar</p>'
  end

  specify "for" do
    get('/simple_for').should == "<div>0</div><div>1</div>"
    get('/simple_for/3').should == "<div>0</div><div>1</div><div>2</div><div>3</div>"
  end
end

rescue LoadError => ex
  puts ex
  puts "Won't run #{__FILE__} unless you install hpricot"
end
