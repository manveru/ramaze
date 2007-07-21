class Page < Ezamar::Element
  def head
    %{
<html>
  <head>
    <title>Wiktacular</title>
    <link rel="stylesheet" type="text/css" media="screen" href="/screen.css" />
  </head>
  <body>
    }
  end

  def menu
%{
    <div id="menu">
      <a href="/main">Home</a>
      <a href="/new">New Entry</a>
    </div>
}
  end

  def navigation
    nodes = Dir['mkd/*'].map{|f|
        name = File.basename(f)
        %[<a href="/#{name}">#{name}</a>]
      }.join("\n")
%{
  <div id="navigation">
    <div id="nodes">
      #{nodes}
    </div>
  </div>
}
  end

  def main
%{
    <div id="manipulate">
      <a href="/edit/\#@handle">Edit</a>
      <a href="/delete/\#@handle">Delete</a>
      <a href="/revert/\#@handle">Revert</a>
      <a href="/unrevert/\#@handle">Unrevert</a>
    </div>
    <div id="content">
      #{content}
    </div>
}
  end

  def render
    head +
      menu +
      navigation +
      main +
      footer
  end

    
  def footer
%{
    <div id="copyright">Wiktacular is powered by <a href="http://ramaze.rubyforge.org/">Ramaze</a></div>
  </body>
</html>
}
  end
end
