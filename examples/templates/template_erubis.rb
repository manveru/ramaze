require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :Erubis

  def index
    %{ #{a('Home', :/)} | #{a(:internal)} | #{a(:external)} }
  end

  def internal *args
    @args = args
    @place = :internal
    %{
<html>
  <head>
    <title>Template::Erubis #@place</title>
  </head>
  <body>
  <h1>The #@place Template for Erubis</h1>
    <%= a('Home', :/) %>
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      <%= a("/#@place/one") %><br />
      <%= a("#@place/two/three") %><br />
      <%= a("#@place/one?foo=bar") %><br />
    </p>
    <div>
      The arguments you have passed to this action are:
      <% if @args.empty? %>
        none
      <% else %>
        <% @args.each do |arg| %>
          <span><%= arg %></span>
        <% end %>
      <% end %>
    </div>
    <div>
      <%= request.params.inspect %>
    </div>
  </body>
</html>
    }
  end

  def external *args
    @args = args
    @place = :external
  end
end

Ramaze.start :file => __FILE__
