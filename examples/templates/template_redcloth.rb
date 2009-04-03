require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :RedCloth
  layout :layout

  def index
    @place = :home
    %{ #{a('Home',:/)} | #{a(:internal)} | #{a(:external)} }
  end

  def internal(*args)
    @place = :internal
    @args = args
    <<__REDCLOTH__
h1. The <%= @place %> Template for RedCloth

"Home":<%= r(:/) %>

Here you can pass some stuff if you like, parameters are just passed like this:<br />
"<%= @place %>/one":<%= r(@place, :one) %><br />
"<%= @place %>/two/three":<%= r(@place, :two, :three) %><br />
"<%= @place %>/one?foo=bar":<%= r(@place, :one, :foo => :bar) %>

The arguments you have passed to this action are:<br />
<% if @args.empty? %>
  none
<% else %>
  <% @args.each do |arg| %>
    <span><%= arg %></span>
  <% end %>
<% end %>

<%= request.params.inspect %>
__REDCLOTH__
  end

  def external(*args)
    @place = :external
    @args = args
  end

  def layout
    <<'__HTML__'
<html>
  <head>
    <title>Template::RedCloth <%= @place %></title>
  </head>
  <body>
    <%= @content %>
  </body>
</html>
__HTML__
  end
end

Ramaze.start :file => __FILE__
