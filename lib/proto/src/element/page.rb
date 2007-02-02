#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
class Page < Element
  def render
    %{
    <html>
      <head>
        <title>Welcome to Ramaze</title>
      </head>
      <body>
        #{content}
      </body>
    </html>
    }
  end
end
