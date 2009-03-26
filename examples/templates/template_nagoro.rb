require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :Nagoro

  def index
    %{ #{a('Home',:/)} | #{a(:internal)} | #{a(:external)} }
  end

  def internal *args
    @args = args
    %q{
<html>
  <head>
    <title>Template::Nagoro internal</title>
  </head>
  <body>
  <h1>The internal Template for Nagoro</h1>
    #{a('Home',:/)}
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      #{a("internal/one")}<br />
      #{a("internal/one/two/three")}<br />
      #{a("internal/one?foo=bar")}<br />
    </p>
    <div>
      The arguments you have passed to this action are:
      <?r if @args.empty? ?>
        none
      <?r else ?>
        <?r @args.each do |arg| ?>
          <span>#{arg}</span>
        <?r end ?>
      <?r end ?>
    </div>
    <div>
      #{request.params.inspect}
    </div>
  </body>
</html>
    }
  end

  def external *args
    @args = args
  end
end

Ramaze.start :file => __FILE__
