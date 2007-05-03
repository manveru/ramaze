require 'spec/helper'

require 'examples/templates/template_amrita2'

describe 'Template Amrita2' do
  ramaze

  it '/external' do
    html = get('/external')
    html.should_not == nil
    html.should =~ %r{<title>Template::Amrita2 external</title>}
    html.should =~ %r{<h1>The external Template for Amrita2</h1>}
  end
end
