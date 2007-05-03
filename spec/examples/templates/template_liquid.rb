require 'spec/helper'

require 'examples/templates/template_liquid'

describe 'Template Liquid' do
  ramaze

  it '/' do
    get('/').should == "<a href=\"/\">index</a> | <a href=\"/internal\">internal</a> | <a href=\"/external\">external</a>"
  end

  %w[/internal /external].each do |url|
    it url do
      html = get(url)
      html.should_not == nil
      html.should =~ %r{<title>Template::Liquid (internal|external)</title>}
      html.should =~ %r{<h1>The (internal|external) Template for Liquid</h1>}
    end
  end
end



