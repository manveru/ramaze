#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

testcase_requires 'amrita2'

class TCTemplateAmritaController < Ramaze::Controller
  trait :template_root => 'spec/ramaze/template/amrita2/'
  trait :engine => Ramaze::Template::Amrita2
  trait :actionless => true

  def title
    "hello world"
  end

  def body
    "Amrita2 is an HTML template library for Ruby"
  end
end

describe "Simply calling" do
  ramaze(:mapping => {'/' => TCTemplateAmritaController})

  it "should respond to /data" do
    get('/data').body.strip.should ==
%{<html>
  <body>
    <h1>hello world</h1>
    <p>Amrita2 is an HTML template library for Ruby</p>
  </body>
</html>}
  end
end
