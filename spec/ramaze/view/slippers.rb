require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'slippers'

Ramaze::App.options.views = 'slippers'

class SpecSlippers < Ramaze::Controller
  map '/'
  engine :Slippers

  def index
    @value = "foo"
    '<h1>Slippers Index with $value$</h1>'
  end

  def sum(num1, num2)
    @num1, @num2 = num1.to_i, num2.to_i
  end

  def external
  end
end

describe 'Ramaze::View::Slippers' do
  behaves_like :rack_test

  should 'render' do
    get('/').body.should == '<h1>Slippers Index with foo</h1>'
  end

  should 'render external template' do
    get('/external').body.strip.
    should == '<html>
  <head>
    <title>Slippers Test</title>
  </head>
  <body>
    <h1>Slippers Template</h1>
  </body>
</html>'
  end

  should 'render external template with instance variables' do
    got = get('/sum/1/2')
    got.status.should == 200
    got['Content-Type'].should == 'text/html'
    got.body.strip.should == "<div>1 and 2</div>"
  end

end
