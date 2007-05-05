#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'hpricot'

class TCMorpherController < Ramaze::Controller
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

  def simple_times n = 1
    @n = n.to_i
    %q{
      <div times="@n">#{_t}</div>
    }
  end

  def simple_each *elem
    @elem = elem
    %q{
      <div each="@elem">#{_e}</div>
    }
  end
end

describe "Morpher" do
  ramaze :mapping => {'/' => TCMorpherController}

  it "testrun" do
    get('/').body.should == 'TCMorpherController'
  end

  it "if" do
    get('/simple_if').body.should == '<p>orig</p>'
    get('/simple_if/bar').body.should == '<p>bar</p>'
  end

  it "unless" do
    get('/simple_unless').body.should == '<p>orig</p>'
    get('/simple_unless/bar').body.should == '<p>bar</p>'
  end

  it "for" do
    get('/simple_for').body.should == "<div>0</div><div>1</div>"
    get('/simple_for/3').body.should == "<div>0</div><div>1</div><div>2</div><div>3</div>"
  end

  it "times" do
    get('/simple_times').body.should == "<div>0</div>"
    get('/simple_times/3').body.should == "<div>0</div><div>1</div><div>2</div>"
  end

  it "each" do
    get('/simple_each').body.should == ''
    get('/simple_each/1/2/3').body.should == "<div>1</div><div>2</div><div>3</div>"
  end
end
