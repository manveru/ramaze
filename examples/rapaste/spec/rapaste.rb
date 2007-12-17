require 'ramaze'
require 'ramaze/spec/helper'

testcase_requires 'ultraviolet', 'hpricot'
base = File.expand_path(__DIR__/'..')
require base/:start

describe 'RaPaste' do
  before :all do
    ramaze :template_root => base/:template, :public_root => base/:public
  end

  it 'should show an empty list on the index page' do
    page = get('/')
    Hpricot(page.body).at('tr.list_empty/td').inner_html.strip.
      should == 'No pastes available yet, go on and <a href="/add">Add one</a>'
  end

  it 'should have a link to the new paste form' do
    page = get('/')
    Hpricot(page.body).at('a[@href=/add]').inner_text.should == 'Add'
  end

  it 'should show a new paste form' do
    page = get('/add')
    form = Hpricot(page.body).at(:form)
    form[:action].should == '/save'
    form[:method].should == 'POST'
    form.at(:textarea)[:name].should == 'text'
    form.at('select/option[@value=plain_text]').inner_text.should == 'Plain Text'
  end

  it 'should create a new paste' do
    page = post('/save', 'syntax' => 'plain_text', 'text' => 'spec paste')
    page.status.should == 303
    page.original_headers['Location'].should == '/1'
  end

  it 'should show the new paste in plain text' do
    page = get('/1.txt')
    page.body.should == 'spec paste'
  end

  it 'should show the new paste in html' do
    page = get('/1')
    (Hpricot(page.body)/'div#paste_body').inner_text.should =~ /spec paste/
  end
end
