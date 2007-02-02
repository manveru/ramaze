#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/spec_helper'

include Ramaze

class TCTemplateAmritaController < Template::Amrita2
  trait :template_root => 'spec/template/amrita2/'

  def title
    "hello world"
  end

  def body
    "Amrita2 is an HTML template library for Ruby"
  end
end

context "Simply calling" do
  ramaze(:mapping => {'/' => TCTemplateAmritaController})

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
