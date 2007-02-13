require 'ramaze'
include Ramaze

class Page < Element
  def render
    %{
     <html>
       <h1>
         #{@hash['title']}
       </h1>
       #{content}
    </html>
    }
  end
end

class SideBar < Element
  def render
    %{
     <div class="sidebar">
       <a href="http://something.com">something</a>
     </div>
     }
  end
end

class MainController < Controller
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

start
