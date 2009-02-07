require 'spec/helper'

Innate.options.app.root = __DIR__
Innate.options.app.view = 'tenjin'

class SpecTenjin < Ramaze::Controller
  map '/'
  provide :html => :rbhtml

  def index
    '<h1>Tenjin Index</h1>'
  end

  def links
    '<ul>
      <li><a href="#{r(:index)}">Index page</a></li>
      <li><a href="#{r(:internal)}">Internal template</a></li>
      <li><a href="#{r(:external)}">External template</a></li>
    </ul>'.ui
  end

  def sum(num1, num2)
    @num1, @num2 = num1.to_i, num2.to_i
  end
end

describe 'Ramaze::View::Tenjin' do
  behaves_like :mock

  should 'render' do
    get('/').body.should == '<h1>Tenjin Index</h1>'
  end

  should 'use other helper methods' do
    get('/links').body.strip.
      should == '<ul>
  <li><a href="/index">Index page</a></li>
  <li><a href="/internal">Internal template</a></li>
  <li><a href="/external">External template</a></li>
</ul>'
  end

  should 'render external template' do
    get('/external').body.strip.
    should == '<html>
  <head>
    <title>Tenjin Test</title>
  </head>
  <body>
    <h1>Tenjin Template</h1>
  </body>
</html>'
  end
end
