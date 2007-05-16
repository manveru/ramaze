#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

class MainController < Controller
  template_root File.expand_path((File.dirname(__FILE__)/'template'))
  trait :engine => Template::Erubis

  def index
    %{ #{link self.class} | #{link self.class, :internal} | #{link self.class, :external} }
  end

  def internal *args
    @args = args
    %q{
<html>
  <head>
    <title>Template::Erubis internal</title>
  </head>
  <body>
  <h1>The <%= @action %> Template for Erubis</h1>
    <%= link :/, :title => 'Home' %>
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      <%= link self, @action, :one, :title => "#@action/one" %><br />
      <%= link self, @action, :one, :two, :three, :title => "#@action/one/two/three" %><br />
      <%= link self, @action, :one, :foo => :bar, :title => "#@action?foo=bar" %><br />
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
  end
end
