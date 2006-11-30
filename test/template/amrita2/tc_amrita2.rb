require 'ramaze'
require 'test/test_helper'

include Ramaze

class MainController < Template::Amrita2
  def title
    "hello world"
  end

  def body
    "Amrita2 is an HTML template library for Ruby"
  end
end

ramaze do
  context "Simply calling" do
    specify "should respond to /data" do
      get('/data').should == "<html>\n  <body>\n    <h1>hello world</h1>\n    <p>Amrita2 is an HTML template library for Ruby</p>\n  </body>\n</html>"
    end
  end
end
