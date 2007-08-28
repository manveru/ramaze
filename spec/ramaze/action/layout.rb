require 'spec/helper'

class TCActionLayout < Ramaze::Controller
  map '/'
  layout :wrapper
  template_root __DIR__ / :template

  def wrapper
    "<pre>#@content</pre>"
  end

  def index
    'Hello, World!'
  end

  def foo
    "bar"
  end
end

class TCActionOtherLayout < Ramaze::Controller
  map '/other'
  layout :other_wrapper
  template_root __DIR__ / :template

  def index
    "Others Hello"
  end
end

class TCActionSingleLayout < Ramaze::Controller
  map '/single'
  template_root __DIR__ / :template
  layout :single_wrapper => :index

  def index
    "Single Hello"
  end

  def without
    "Without wrapper"
  end
end

class TCActionDenyLayout < Ramaze::Controller
  map '/deny'
  template_root __DIR__/:template
  layout :single_wrapper
  deny_layout :without

  def index
    "Single Hello"
  end

  def without
    "Without wrapper"
  end
end

class TCActionMultiLayout < Ramaze::Controller
  map '/multi'
  template_root __DIR__/:template
  layout :single_wrapper => [:index, :second]
  p trait

  def index
    "Single Hello"
  end

  def second
    "Second with layout"
  end

  def without
    "Without wrapper"
  end
end

describe 'Action rendering' do
  before :all do
    ramaze
  end

  it 'should work with layouts' do
    get('/').body.should == "<pre>Hello, World!</pre>"
    get('/foo').body.should == "<pre>bar</pre>"
    get('/bar').body.should == "<pre>Hello from bar</pre>"
  end

  it 'should work with layout from file' do
    get('/other').body.should == "<p>Others Hello</p>"
    get('/other/bar').body.should == "<p>Hello from bar</p>"
  end

  it 'should apply single layout' do
    get('/single').body.should == "<b>Single Hello</b>"
    get('/single/without').body.should == "Without wrapper"
  end

  it 'should deny a single action' do
    get('/deny').body.should == "<b>Single Hello</b>"
    get('/deny/without').body.should == "Without wrapper"
  end

  it 'should apply layout to a list of actions' do
    get('/multi').body.should == "<b>Single Hello</b>"
    get('/multi/second').body.should == "<b>Second with layout</b>"
    get('/multi/without').body.should == "Without wrapper"
  end
end
