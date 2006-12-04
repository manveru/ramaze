require 'lib/test/test_helper'

include Ramaze

class MainController < Template::Amrita2
  trait :template_root => 'template/amrita2/'

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
      get('/data').should == 
%{<html>
  <body>
    <h1>hello world</h1>
    <p>Amrita2 is an HTML template library for Ruby</p>
  </body>
</html>}
    end
  end
end
