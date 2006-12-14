class Page < Ramaze::Element
  def render(*args)
    %{
<html>
  <head>
    <title>#{@title}</title>
    <link href="/screen.css" type="text/css" rel="stylesheet">
  </head>
  <body>
    <div id="menu">
      #{link MainController, :/, :title => 'Home'}
      &middot;
      #{link EntryController, :/, :title => 'Blog'}
      <span id="title"><a href="#{R :/}">#{@title || 'Blogging Ramaze'}</a></span>
    </div>
    #{content}
  </body>
</html>
    }
  end
end
