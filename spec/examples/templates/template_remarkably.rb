require 'spec/helper'

testcase_requires 'remarkably/engines/html'
require 'examples/templates/template_remarkably'

describe 'Template Remarkably' do
  ramaze

  it '/' do
    get('/').body.strip.should ==
      "<a href=\"/\">Home</a> | <a href=\"/internal\">internal</a> | <a href=\"/external\">external</a>"
  end

  %w[/internal /external].each do |url|
    it url do
      html = get(url).body
      html.should_not == nil
      html.should =~ %r{<title>Template::Remarkably (internal|external)</title>}
      html.should =~ %r{<h1>The (internal|external) Template for Remarkably</h1>}
    end
  end
end
