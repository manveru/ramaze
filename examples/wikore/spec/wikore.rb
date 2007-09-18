require 'ramaze'
require 'ramaze/spec/helper'

# if these libraries are missing there is no sense in running the tests,
# cause they won't work at all. 
testcase_requires 'hpricot'
testcase_requires 'sequel'

$:.unshift __DIR__/'../'
require 'start'

describe 'Wikore' do
  def should_redirect to = '/'
    response = yield
    response.status.should == 303
    response.body.should =~ /<a href="#{to}">/
  end

  def page_should_exist(name, *matches)
    page = get("/#{name}")
    page.status.should == 200
    matches.each do |match|
      page.body.should =~ match
    end
  end

  before :all do
    ramaze :template_root => (__DIR__/'../template')
  end

  it 'should have no Main page' do
    page = get('/Main')
    page.status.should == 200
    page.body.should =~ /No Page known as 'Main'/
  end

  it 'should create a Main page' do
    should_redirect '/Main' do
      post('/page/create', 'title' => 'Main', 'text' => 'Newly created Main page')
    end

    matches = [
      /Newly created Main page/,
      /Version: 1/
    ]
    page_should_exist('Main', *matches)
  end

  it 'should update Main page' do
    should_redirect '/Main' do
      post('/page/save', 'title' => 'Main', 'text' => 'Newly updated Main page')
    end

    matches = [
      /Newly updated Main page/,
      /Version: 2/
    ]
    page_should_exist('Main', *matches)
  end

  it 'should maintain a backup' do
    matches = [
      /Newly created Main page/,
      /Version: 1/
    ]
    page_should_exist('Main/1', *matches)
  end

  it 'should revert' do
    get('/page/revert/Main')

    matches = [
      /Newly created Main page/,
      /Version: 1/
    ]
    page_should_exist('Main', *matches)
  end


  it 'should incrememt version of Main page' do
    (2..4).each do |n|
      post('/page/save', 'title' => 'Main', 'text' => 'updated Main page')

      matches = [ /updated Main page/, /Version: #{n}/ ]
      page_should_exist('Main', *matches)
    end
  end

  it 'should rename Main page to Other and back' do
    should_redirect '/Other' do
      get('/page/rename/Main/Other')
    end
    should_redirect '/Main' do
      get('/page/rename/Other/Main')
    end
  end

  it 'should delete Main page' do
    get('/page/delete/Main')

    page_should_exist('Main', /No Page known as 'Main'/)
  end

  it 'should fail if create/save is not POSTed to' do
    should_redirect '/' do
      get('/page/save', 'title' => 'Main', 'text' => 'Newly updated Main page')
    end
    should_redirect '/' do
      get('/page/create', 'title' => 'Main', 'text' => 'Newly updated Main page')
    end
  end

  after :all do
    FileUtils.rm('wikore.db')
  end
end
