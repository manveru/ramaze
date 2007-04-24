class Page < Controller
  attr_accessor :content
  helper :auth

  def initialize content
    @content = content
  end

  def render
    %{
<html>
  <head>
    <title>#{@title}</title>
    <link href="/screen.css" type="text/css" rel="stylesheet">
    <script type="text/javascript">
    function removeResult() {
      document.getElementById( 'result' ).style.display = "none";
    }
    </script>
  </head>
  <body onload="javascipt:setTimeout('removeResult();',1500)">
    #{result}
    #{menu}
    #{sidebar}
    #{content}
  </body>
</html>
    }
  end

  def result
    if session[:result]
      result_message = %{<div id="result">#{session[:result]}</div>}
      session[:result] = nil
    else
      result_message = %{<div id="result" style="display:none"></div>}
    end
    result_message
  end

  def menu
    %{
    <div id="menu">
      <span id="title">
        <a href="#{R :/}">#{@title || 'Blogging Ramaze'}</a>
      </span>
      <?r if logged_in? ?>
        <span id="login"> #{link R(:logout), :title => 'logout'} </span>
      <?r else ?>
        <span id="login"> #{link R(:login), :title => 'login'} </span>
      <?r end ?>
    </div>
    }
  end

  def sidebar
    entries =
      Entry.all.map do |eid, e|
      %{
        <div>
          #{link R(:/, :view, eid), :title => e.title}
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
