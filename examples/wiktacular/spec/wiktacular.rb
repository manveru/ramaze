require 'ramaze'
require 'ramaze/spec/helper'

# if these libraries are missing there is no sense in running the tests,
# cause they won't work at all. 
testcase_requires 'bluecloth'
testcase_requires 'hpricot'

$:.unshift 'examples/wiktacular'
require 'start'

# fix the paths to template and public for the spec
# this is not needed usually, but this tests are also part of ramaze's suite
class MainController
  template_root __DIR__ / '../template'
end

describe 'wiktacular' do

  def check_page(name)
    page = get('/'+name)
    page.status.should == 200
    page.body.should_not be_nil

    doc = Hpricot(page.body)
    doc.at('title').inner_html.should == 'Wiktacular'

    menu = doc.search('div#menu>a')
    menu[0].inner_html.should == 'Home'
    menu[1].inner_html.should == 'New Entry'

    navigation = doc.search('div#navigation>div>a')
    %w[link main markdown testing].each do |link|
      navigation.map{|n| n.inner_html }.sort.should include(link)
    end

    manipulate = doc.search('div#manipulate>a')
    manipulate.map{|m| m.inner_html }.should ==
      %w[Edit Delete Revert Unrevert]

    doc
  end

  it 'should start' do
    ramaze :public_root => 'examples/wiktacular/public', :port => 7001
    get('/').status.should == 200
  end

  it 'should have main page' do
    check_page('/main')
  end

  it 'should have link page' do
    check_page('/link')
  end

  it 'should have markdown page' do
    check_page('/markdown')
  end

  it 'should have testing page' do
    check_page('/testing')
  end


  it 'should not have foobar page' do
    doc = check_page('/foobar')
    doc.at('div#text').inner_html.strip.should == 'No Entry'
  end 

  it 'should allow page editing' do
    doc = check_page('/edit/main')
    form = doc.at('div#content>form')
    form.at('input[@type=text]')['value'].should == 'main'
    form.at('textarea').inner_html.should match(/# Hello, World/)
    form.at('a').inner_html.should == 'cancel'
    form.at('a')['href'].should == '/main'
  end

  def edit_page(name, text='new text')
    page = post('/save','handle'=>name,'text'=>text) 
    page.status.should == 303
    page.location.should == '/index/'+name
  end
  def delete_page(name)
    page = get('/delete/'+name)
    page.status.should == 303
    page.location.should == '/'
  end
  it 'editing should create page' do
    edit_page('newpage', 'new text')
    doc = check_page('newpage')
    doc.at('div#text').inner_html.strip.should == '<p>new text</p>'
    delete_page('newpage')
  end

  it 'editing should modify page' do
    edit_page('editable', 'text text')
    doc = check_page('editable')
    doc.at('div#text').inner_html.strip.should == '<p>text text</p>'
    edit_page('editable','some other text')
    doc = check_page('editable')
    doc.at('div#text').inner_html.strip.should == '<p>some other text</p>'
    delete_page('editable')
  end

  after :all do
    mkd = __DIR__ / '../mkd/'
    keep = %w{link markdown main testing}.map {|x| mkd/x}
    Dir[mkd/'*'].each do |dir|
      FileUtils.rm_r dir unless keep.include? dir
    end
  end

end
