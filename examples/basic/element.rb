require 'rubygems'
require 'ramaze'
require 'nagoro'

class Page < Nagoro::Element
  def render
    %{
     <html>
      <head>
        <title>examples/element</title>
      </head>
      <body>
        <h1>#{@title}</h1>
        #{content}
      </body>
    </html>
    }
  end
end

class SideBar < Nagoro::Element
  def render
    %{
     <div class="sidebar">
       <a href="http://something.com">something</a>
     </div>
     }
  end
end

class MainController < Ramaze::Controller
  map '/'
  engine :Nagoro

  def index
    %{
    <Page title="Test">
      <SideBar />
      <p>
        Hello, World!
      </p>
    </Page>
    }
  end
end

Ramaze.start
