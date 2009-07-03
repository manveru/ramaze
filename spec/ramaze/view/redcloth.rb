#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_requires 'erubis', 'redcloth'

Ramaze::App.options.views = 'redcloth'

class SpecRedCloth < Ramaze::Controller
  map '/'
  engine :RedCloth

  def index
    'h1. RedCloth Index'
  end

  def links
    '<ul>
      <li><%= a("Index page", :index) %></li>
      <li><%= a("Internal template", :internal) %></li>
      <li><%= a("External template", :external) %></li>
    </ul>'.ui
  end

  def internal
    "h2. <%= 1 + 1 %>"
  end
end

describe "Ramaze::View::RedCloth" do
  behaves_like :rack_test

  should 'render' do
    got = get('/')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.should == '<h1>RedCloth Index</h1>'
  end

  it "uses helper methods" do
    got = get('/links')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
'<ul>
  <li><a href="/index">Index page</a></li>
  <li><a href="/internal">Internal template</a></li>
  <li><a href="/external">External template</a></li>
</ul>'
  end

  it 'renders external templates' do
    got = get('/external')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
"<html>
<head>
    <title>Erubis Test</title>
</head>
<body>
<h1>RedCloth Template</h1>
</body>
</html>"
  end
end
