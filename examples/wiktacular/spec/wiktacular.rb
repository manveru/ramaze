require 'ramaze/spec/helper'

#testcase_requires 'bluecloth'
testcase_requires 'hpricot'

$:.unshift 'examples/wiktacular'
require 'start'

# fix the paths to template and public for the spec
# this is not needed usually, but this tests are also part of ramaze's suite
class MainController
  template_root File.expand_path(File.dirname(__FILE__)/'../template')
end

describe 'wiktacular' do

  def check_page(name)
    page = get(name)
    page.status.should == 200
    page.body.should_not be_nil

    doc = Hpricot(page.body)
    doc.at('title').inner_html.should == 'Wiktacular'

    menu = doc.search('div#menu>a')
    menu[0].inner_html.should == 'Home'
    menu[1].inner_html.should == 'New Entry'

    navigation = doc.search('div#navigation>div>a')
    navigation[0].inner_html.should == 'testing'
    navigation[1].inner_html.should == 'link'
    navigation[2].inner_html.should == 'markdown'
    navigation[3].inner_html.should == 'main'

    manipulate = doc.search('div#manipulate>a')
    manipulate[0].inner_html.should == 'Edit'
    manipulate[1].inner_html.should == 'Delete'
    manipulate[2].inner_html.should == 'Revert'
    manipulate[3].inner_html.should == 'Unrevert'

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
end
