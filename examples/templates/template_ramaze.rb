#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

class MainController < Template::Ramaze
  def index
    %{ #{link self.class} | #{link self.class, :internal} | #{link self.class, :external} }
  end

  def internal *args
    @args = args
    transform %q{
<html>
  <head>
    <title>Template::Ramaze internal</title>
  </head>
  <body>
  <h1>The #{@action} Template</h1>
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      #{link self, @action, :one, :title => 'external/one'}<br />
      #{link self, @action, :one, :two, :three, :title => 'external/one/two/three'}<br />
      #{link self, @action, :one, :foo => :bar, :title => 'external?foo=bar'}<br />
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
