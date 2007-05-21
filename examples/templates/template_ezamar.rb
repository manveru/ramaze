#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

class MainController < Ramaze::Controller
  template_root File.expand_path((File.dirname(__FILE__)/'template'))

  def index
    %{ #{link self.class} | #{link self.class, :internal} | #{link self.class, :external} }
  end

  def internal *args
    @args = args
    %q{
<html>
  <head>
    <title>Template::Ezamar internal</title>
  </head>
  <body>
  <h1>The internal Template for Ezamar</h1>
    #{link :/, :title => 'Home'}
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      #{link Rs(:internal, :one), :title => "/internal/one"}<br />
      #{link Rs(:internal, :one, :two, :three), :title => "/internal/one/two/three"}<br />
      #{link Rs(:internal, :one, :foo => :bar), :title => "/internal?foo=bar"}<br />
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

Ramaze.start
