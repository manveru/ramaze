require 'ramaze'
require 'ramaze/spec/helper'

# if these libraries are missing there is no sense in running the tests,
# cause they won't work at all.
testcase_requires 'bluecloth', 'hpricot', 'nagoro'

$:.unshift 'examples/whywiki'

Db = Ramaze::YAMLStoreCache.new('testwiki.yaml')
require 'start'

class WikiController < Ramaze::Controller
  template_root __DIR__ / '../template'
end

describe WikiController do
  after :all do
    FileUtils.rm('testwiki.yaml')
  end

  def page(name)
    page = get('/'+name)
    page.status.should == 200
    page.body.should_not be_nil

    doc = Hpricot(page.body)
    title = doc.at('title').inner_html

    body = doc.at('body')
    return title, body
  end

  it 'should start' do
    ramaze :public_root => '.', :port => 7001
    get('/').status.should == 303
  end

  it 'should have main page' do
    t,body = page('/show/Home')
    t.should match(/^MicroWiki Home$/)
    body.at('h1').inner_html.should == 'Home'
    body.at('a[@href=/edit/Home]').inner_html.should == 'Create Home'
  end

  it 'should have edit page' do
    t,body = page('/edit/Home')
    t.should match(/^MicroWiki Edit Home$/)

    body.at('a[@href=/]').inner_html.should == '&lt; Home'
    body.at('h1').inner_html.should == 'Edit Home'
    body.at('form[@action=/save]>textarea[@name=text]').should_not be_nil
  end

  it 'should create pages' do
    post('/save','text'=>'the text','page'=>'ThePage').status.should == 303
    page = Hpricot(get('/show/ThePage').body)
    body = page.at('body>div')
    body.should_not be_nil
    body.at('a[@href=/edit/ThePage]').inner_html.should =='Edit ThePage'
    body.at('p').inner_html.should == 'the text'
  end
end
