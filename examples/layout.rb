require 'ramaze'
include Ramaze

class SideBar < Ezamar::Element
  def render
    %{
     <div class="sidebar">
       <a href="http://something.com">something</a>
     </div>
     }
  end
end

class MainController < Controller
  map '/'
  layout :page

  def index
    @title = "Test"
    %{
    <SideBar />
    <p>Hello, World!</p>
    }
  end

  def page
    %{
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
