#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'spec/helper'

spec_require 'amrita2'

class TCTemplateAmritaController < Ramaze::Controller
  template_root __DIR__/:amrita2
  engine :Amrita2

  private

  def title
    "hello world"
  end

  def body
    "Amrita2 is an HTML template library for Ruby"
  end
end

describe "Simply calling" do
  behaves_like 'http'
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
