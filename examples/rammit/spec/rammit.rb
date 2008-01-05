require 'ramaze'
require 'ramaze/spec/helper'

$LOAD_PATH.unshift base = __DIR__/'..'
testcase_requires 'hpricot'

require 'start'

describe 'Rammit' do
  behaves_like 'http'
  base = File.expand_path(__DIR__/'..')
  ramaze :template_root => base/'template', :public_root => base/'public'

  it 'should have intro page' do
    got = get('/')
    doc = Hpricot(got.body)
    form = doc.at(:form)
    form.at('textarea[@name=text]').should.not == nil
    form.at('input[@type=submit @value="Create a site"]').should.not == nil
  end

  it 'should create page from intro page' do
    got = post('/page/create', 'text' => 'Some text')
    refer = got.headers['Location']
    refer.should.not == nil
    got = get(refer)
    doc = Hpricot(got.body)
    doc.at('div#text').inner_html.should =~ /Some text/
  end
end
