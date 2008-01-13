#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'ramaze/helper/link'

class TCLink < Ramaze::Controller
  map '/'
  def index; end
end

class TCLink2 < Ramaze::Controller
  map '/2'
  def index; end
end

ramaze

describe "A" do
  extend Ramaze::LinkHelper

  before do
    # initialize Ramaze::Controller.current for Rs()
    Ramaze::Controller.handle('/')
  end

  it 'should build links' do
    A('title', :href => '/').should == %(<a href="/">title</a>)
    A('title', :href => '/foo').should == %(<a href="/foo">title</a>)
    A('title', :href => '/foo?x=y').should == %{<a href="/foo?x=y">title</a>}
    A('/foo?x=y').should == %{<a href="/foo?x=y">/foo?x=y</a>}

    a = A('title', :href => '/foo', :class => :none)
    a.should =~ /class="none"/
    a.should =~ /href="\/foo"/
  end

  it 'should build position independend links' do
    A(TCLink, :foo).should == %(<a href="/foo">foo</a>)
  end
end

describe 'R' do
  extend Ramaze::LinkHelper

  it 'should build urls' do
    R(TCLink).should == '/'
    R(TCLink, :foo).should == '/foo'
    R(TCLink, :foo, :bar).should == '/foo/bar'
    R(TCLink, :foo, :bar => :baz).should == '/foo?bar=baz'
  end
end

describe 'Rs' do
  extend Ramaze::LinkHelper

  it 'should build links for current controller' do
    Ramaze::Controller.handle('/2')
    Rs(:index).should == '/2/index'

    Ramaze::Controller.handle('/')
    Rs(:index).should == '/index'
  end

  it 'should treat Rs() like R() when Controller given' do
    Ramaze::Controller.handle('/2')
    Rs(TCLink, :index).should == '/2/index'
  end

end

describe 'breadcrumbs' do
  extend Ramaze::LinkHelper

  it 'should lay out breadcrumbs' do
    breadcrumbs('/file/dir/listing/is/cool').
      should == [
      "<a href=\"/file\">file</a>",
      "<a href=\"/file/dir\">dir</a>",
      "<a href=\"/file/dir/listing\">listing</a>",
      "<a href=\"/file/dir/listing/is\">is</a>",
      "<a href=\"/file/dir/listing/is/cool\">cool</a>"
    ].join('/')
  end

  it 'should lay out breadcrumbs with href prefix' do
    breadcrumbs('/file/dir/listing/is/cool', '/', '/', '/prefix/path').
      should == [
      "<a href=\"/prefix/path/file\">file</a>",
      "<a href=\"/prefix/path/file/dir\">dir</a>",
      "<a href=\"/prefix/path/file/dir/listing\">listing</a>",
      "<a href=\"/prefix/path/file/dir/listing/is\">is</a>",
      "<a href=\"/prefix/path/file/dir/listing/is/cool\">cool</a>"
    ].join('/')
  end
end
