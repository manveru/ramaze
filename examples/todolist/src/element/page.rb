#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class Page < Ezamar::Element
  def render
    %{
    <html>
      <head>
        <title>TodoList</title>
      </head>
      <body>
        <h1>#{@hash['title']}</h1>
        #{content}
      </body>
    </html>
    }
  end
end
