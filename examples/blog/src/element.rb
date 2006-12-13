class Page < Ramaze::Element
  def render
    %{
<html>
  <head>
    <title>#{@title}</title>
    <link href="/screen.css" type="text/css" rel="stylesheet">
  </head>
  <body>
    <div id="title"><a href="#{R :/}">#{@title || 'Blogging Ramaze'}</a></div>
    #{content}
  </body>
</html>
    }
  end
end
