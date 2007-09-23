require 'ramaze'
require 'ramaze/spec/helper'

# if these libraries are missing there is no sense in running the tests,
# cause they won't work at all. 
testcase_requires 'og'
testcase_requires 'hpricot'

# Og sets this in the global namespace and uses the STDERR to write messages
# We can replace it with Ramaze's logger that does The Right Thing (TM)
class Logger
  @@global_logger = Ramaze::Inform
end
$:.unshift 'examples/blog'
require 'start'

# fix the paths to template and public for the spec
# this is not needed usually, but this tests are also part of ramaze's suite
class MainController
  template_root __DIR__ / '../template'
end

describe 'blog' do

  def check_page(name)
    page = get('/'+name)
    page.status.should == 200
    page.body.should_not be_nil

    doc = Hpricot(page.body)
    doc.at('title').inner_html.should == 'bl_Og'
    doc.at('h1').inner_html.should == 'bl_Og'

    doc.search('div#entries').length.should == 1

    doc
  end

  it 'should start' do
    ramaze :public_root => 'examples/blog/public', :port => 7001
    get('/').status.should == 200
  end

  it 'should have main page' do
    doc = check_page('')
    doc.at('div#actions>a').inner_html.should == 'new entry'
    doc.search('div.entry').length.should == 1
  end

  it 'should have new entry page' do
    doc = check_page('new')
    form = doc.at('div.entry>form')
    form.at('input[@name=title]')['value'].should == ''
    form.at('textarea').inner_html.should == ''
    form.at('input[@type=submit]')['value'].should == 'Add Entry'
  end

  def create_page(title,content)
    page = post('/create','title'=>title,'content'=>content)
    page.status.should == 303
    page.location.should == '/'
  end
  
  it 'should add new pages' do
    create_page('new page', 'cool! a new page')
    doc = check_page('')
    entry = doc.search('div.entry')
    entry.length.should == 2
    entry = entry.last

    entry.at('div.title').inner_html == 'new page'
    entry.at('div.content').inner_html == 'cool! a new page'
  end

  it 'should edit existing pages' do
    create_page('new page', 'cool! a new page')
    post('/save','oid'=>'2','title'=>'new title','content'=>'bla bla')
    doc = check_page('')
    entry = doc.search('div.entry')
    entry.length.should == 2
    entry = entry.first

    entry.at('div.title').inner_html == 'new title'
    entry.at('div.content').inner_html == 'bla bla'
  end

  it 'should delete existing pages' do
    create_page("page to delete", 'content')
    check_page('').search('div.entry').length.should == 2
    page = get('/delete/2')
    page.status.should == 303
    page.location.should == '/'
    check_page('').search('div.entry').length.should == 1
  end

  after do
    Entry.all.each do |e|
      e.delete unless e.oid == 1
    end
  end

end
