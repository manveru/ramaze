require 'ramaze'
require 'ramaze/spec/helper'

# if these libraries are missing there is no sense in running the tests,
# cause they won't work at all. 
testcase_requires 'sequel'
testcase_requires 'hpricot'

require 'start'

describe 'blog' do
  def check_page(name = '')
    page = get("/#{name}")
    page.status.should == 200
    page.body.should_not be_nil

    doc = Hpricot(page.body)
    doc.at('title').inner_html.should == 'bl_Og'
    doc.at('h1').inner_html.should == 'bl_Og'

    doc.search('div#entries').should have(1).div

    doc
  end

  def create_page(title,content)
    page = post('/create','title'=>title,'content'=>content)
    page.status.should == 303
    page.location.should == '/'
  end

  before :all do
    ramaze :public_root   => __DIR__/'../public',
           :template_root => __DIR__/'../template'
  end

  it 'should have main page' do
    doc = check_page
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
  
  it 'should add new pages' do
    create_page('new page', 'cool! a new page')
    doc = check_page
    entry = doc.search('div.entry')
    entry.length.should == 2
    entry = entry.last

    entry.at('div.title').inner_html == 'new page'
    entry.at('div.content').inner_html == 'cool! a new page'
  end

  it 'should edit existing pages' do
    create_page('new page', 'cool! a new page')
    post('/save','id'=>'2','title'=>'new title','content'=>'bla bla')
    doc = check_page
    entries = doc/'div.entry'
    entries.should have(2).divs
    entry = entries.first

    entry.at('div.title').inner_html == 'new title'
    entry.at('div.content').inner_html == 'bla bla'
  end

  it 'should delete existing pages' do
    create_page("page to delete", 'content')
    entries = check_page/'div.entry'
    entries.should have(2).divs
    delete_link = entries.last.at("a:contains('delete')")
    page = get(delete_link[:href])
    page.status.should == 303
    page.location.should == '/'
    (check_page/'div.entry').should have(1).div
  end

  after :each do
    Entry.each{|e| e.delete unless e.id == 1 }
  end

  after :all do
    FileUtils.rm_f(__DIR__/'../blog.db')
  end
end
