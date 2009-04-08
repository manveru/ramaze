require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  layout :page
  provide :html => :nagoro

  def index
    @title = "Test"
    "<p>Hello, World!</p>"
  end

  def page
    %q{
<html>
  <head>
    <title>examples/layout</title>
  </head>
  <body>
    <h1>#@title</h1>
    #@content
  </body>
</html>
    }
  end
end

Ramaze.start
