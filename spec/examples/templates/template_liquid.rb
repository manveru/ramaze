require 'spec/helper'

testcase_requires 'liquid'
require 'examples/templates/template_liquid'

describe 'Template Liquid' do
  ramaze

  it '/' do
    get('/').body.strip.should ==
      "<a href=\"/\">Home</a> | <a href=\"/internal\">internal</a> | <a href=\"/external\">external</a>"
  end

  %w[/internal /external].each do |url|
    it url do
      html = get(url).body
      html.should_not == nil
      html.should =~ %r{<title>Template::Liquid (internal|external)</title>}
      html.should =~ %r{<h1>The (internal|external) Template for Liquid</h1>}
    end
  end
end



