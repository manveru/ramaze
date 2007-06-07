#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'hpricot'

class TCMorpherController < Ramaze::Controller
  map '/'

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
  before :all do
    ramaze
    pipeline = Ramaze::Template::Ezamar::TRANSFORM_PIPELINE
    pipeline.clear
    pipeline.push(Ezamar::Element, Ezamar::Morpher)
  end

  def clean_get(*url)
    get(*url).body.split("\n").join.strip
  end

  it "testrun" do
    clean_get('/').should == 'TCMorpherController'
  end

  it "if" do
    clean_get('/simple_if').should == '<p>orig</p>'
    clean_get('/simple_if/bar').should == '<p>bar</p>'
  end

  it "unless" do
    clean_get('/simple_unless').should == '<p>orig</p>'
    clean_get('/simple_unless/bar').should == '<p>bar</p>'
  end

  it "for" do
    clean_get('/simple_for').should == "<div>0</div><div>1</div>"
    clean_get('/simple_for/3').should == "<div>0</div><div>1</div><div>2</div><div>3</div>"
  end

  it "times" do
    clean_get('/simple_times').should == "<div>0</div>"
    clean_get('/simple_times/3').should == "<div>0</div><div>1</div><div>2</div>"
  end

  it "each" do
    clean_get('/simple_each').should == ''
    clean_get('/simple_each/1/2/3').should == "<div>1</div><div>2</div><div>3</div>"
  end
end
