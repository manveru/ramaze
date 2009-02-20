#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

Ramaze.options.app.root = __DIR__
Ramaze.options.app.view = 'amrita2'

class SpecAmrita2 < Ramaze::Controller
  map '/'
  provide :html => :amr

  def index
    @data = {:title => 'Amrita2 Index'}
    "<h1 am:src='title' />"
  end

  def external
    @data = {
      :title => 'Amrita2 Test',
      :header => 'Amrita2 Template'
    }
  end

  def links
    @data = {
      :links => [
        {:to => r(:index),    :title => 'Index page'},
        {:to => r(:internal), :title => 'Internal template'},
        {:to => r(:external), :title => 'External template'}]}

%(
<ul>
  <li am:src="links">
    <a am:filter='NVar[:to, :title]' href="$1">$2</a>
  </li>
</ul>
).strip
  end

  def sum(num1, num2)
    @data = {:num1 => num1.to_i, :num2 => num2.to_i}
  end
end

describe "Ramaze::View::Amrita2" do
  behaves_like :mock

  should 'render' do
    got = get('/')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "<h1>Amrita2 Index</h1>"
  end

  should 'use other helper methods' do
    got = get('/links')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
'<ul>
  <li>
    <a href="/index">Index page</a>
  </li><li>
    <a href="/internal">Internal template</a>
  </li><li>
    <a href="/external">External template</a>
  </li>
</ul>'
  end

  should 'render external template' do
    got = get('/external')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should ==
"<html>
  <head>
    <title>Amrita2 Test</title>
  </head>
  <body>
    <h1>Amrita2 Template</h1>
  </body>
</html>"
  end

  should 'render external template with instance variables' do
    got = get('/sum/1/2')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "1 + 2 = 3"
  end
end
