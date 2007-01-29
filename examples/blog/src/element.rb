class Page < Ramaze::Element
  include Trinity
  helper :auth

  def render
    %{
<html>
  <head>
    <title>#{@title}</title>
    <link href="/screen.css" type="text/css" rel="stylesheet">
  </head>
  <body>
    #{menu}
    #{sidebar}
    #{content}
  </body>
</html>
    }
  end

  def menu
    %{
    <div id="menu">
      <span id="title">
        <a href="#{R :/}">#{@title || 'Blogging Ramaze'}</a>
      </span>
      <?r if check_login ?>
        <span id="login"> #{link R(:logout), :title => 'logout'} </span>
      <?r else ?>
        <span id="login"> #{link R(:login), :title => 'login'} </span>
      <?r end ?>
    </div>
    }
  end

  def sidebar
    entries =
      Entry.all.map do |e|
      %{
        <div>
          #{link R(:/, :view, e.oid), :title => e.title}
        </div>
      }
    end

    %{
    <div id="sidebar">
      <h1>Recent Entries</h1>
      #{entries}
    </div>
    }
  end
end
