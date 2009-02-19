#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

# This spec more or less tries to ensure that we integrate with rack and
# rack-contrib in regards to static file serving.

module Ramaze
  # minimal middleware, no exception handling
  middleware!(:innate){|m|
    m.use(Rack::ETag, Rack::ConditionalGet)
    m.innate
  }
end

describe 'Serving static files' do
  behaves_like :mock

  Ramaze.options.app.root = __DIR__
  Ramaze.options.app.public = '/public'
  Ramaze.map('/', lambda{|env| [200, {}, 'nothing']})

  it 'serves from public root' do
    css = File.read(__DIR__('public/test_download.css'))
    got = get('/test_download.css')
    got.body.should == css
    got.status.should == 200
  end

  it 'serves files with spaces' do
    got = get('/file%20name.txt')
    got.status.should == 200
    got.body.should == 'hi'
  end

  it 'sends ETag for string bodies' do
    got = get('/')
    got['ETag'].size.should == 34
  end

  it 'sends Last-Modified for file bodies' do
    got = get('/test_download.css')

    mtime = File.mtime(__DIR__('public/test_download.css'))

    got['Last-Modified'].should == mtime.httpdate
  end

  it 'respects ETag with HTTP_IF_NONE_MATCH' do
    got = get('/')

    etag = got['ETag']
    etag.should.not.be.nil

    got = get('/', 'HTTP_IF_NONE_MATCH' => etag)
    got.status.should == 304
    got.body.should == ''
  end

  it 'respects Last-Modified with HTTP_IF_MODIFIED_SINCE' do
    got = get('/test_download.css')

    mtime = got['Last-Modified']
    mtime.should.not.be.nil

    got = get('/test_download.css', 'HTTP_IF_MODIFIED_SINCE' => mtime)
    got.status.should == 304
    got.body.should == ''
  end
end
