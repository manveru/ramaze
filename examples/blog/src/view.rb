class Blog < Ezamar::Element
  def render
    %(
    <html>
      <head>
        <title>bl_Og</title>
        <link rel="stylesheet" href="/styles/blog.css" type="text/css"/>
      </head>
      <body>
        <h1>#{@title}</h1>
        #{content}
      </body>
    </html>
    )
  end
end
