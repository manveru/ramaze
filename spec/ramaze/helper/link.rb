#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'
require 'ramaze/helper/link'

class SpecHelperLink < Ramaze::Controller
  map '/'
end

class SpecHelperLinkTwo < Ramaze::Controller
  map '/two'
end

describe Ramaze::Helper::Link do
  extend Ramaze::Helper::Link

  it 'builds routes' do
    R(SpecHelperLink, :foo).should == '/foo'
    SpecHelperLink.Rs(:foo).should == '/foo'
  end

  it 'builds links' do
    SpecHelperLink.A(:foo).should == '<a href="/foo">foo</a>'
    SpecHelperLink.A(:foo, :bar).should == '<a href="/bar">foo</a>'
  end

  it 'lays out breadcrumbs' do
    SpecHelperLink.breadcrumbs('/file/dir/listing/is/cool').
      should == [
      '<a href="/file">file</a>',
      '<a href="/file/dir">dir</a>',
      '<a href="/file/dir/listing">listing</a>',
      '<a href="/file/dir/listing/is">is</a>',
      '<a href="/file/dir/listing/is/cool">cool</a>'
    ].join('/')
  end

  it 'lays out breadcrumbs with href prefix' do
    SpecHelperLink.breadcrumbs('/file/dir/listing/is/cool', '/', '/', '/prefix/path').
      should == [
      '<a href="/prefix/path/file">file</a>',
      '<a href="/prefix/path/file/dir">dir</a>',
      '<a href="/prefix/path/file/dir/listing">listing</a>',
      '<a href="/prefix/path/file/dir/listing/is">is</a>',
      '<a href="/prefix/path/file/dir/listing/is/cool">cool</a>'
    ].join('/')
  end
end
