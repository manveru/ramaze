require 'ramaze'
include Ramaze

class Page < Template::Ramaze::Element
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

class SideBar < Template::Ramaze::Element
  def render
    %{
     <div class="sidebar">
       <a href="http://something.com">something</a>
     </div>
     }
  end
end

class MainController < Template::Ramaze
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
