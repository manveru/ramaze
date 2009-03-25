require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :Amrita2

  def index
    %{ #{a('Home', :/)} | #{a(:internal)} | #{a(:external)} }
  end

  def internal(*args)
    @data = binding
    @place = :internal
    <<__AMRITA2__
<html>
  <head>
    <title>Template::Amrita2 external</title>
  </head>
  <body>
  <h1 am:src="title" />
    <%= link_home %>
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      <%= link_one %><br />
      <%= link_two %><br />
      <%= link_three %>
    </p>
    <<div<
      <<:args<
        <span><%= $_ %></span>
    <%= inspect_parameters %>
  </body>
</html>
__AMRITA2__
  end

  def external(*args)
    @data = binding
    @place = :external
  end

  private

  def title
    "The #{@place} Template for Amrita2"
  end

  def link_home
    a('Home', :/)
  end

  def link_one
    a("/#{@place}/one", Rs(@place, :one))
  end

  def link_two
    a("/#{@place}/one/two/three", Rs(@place, :one, :two, :three))
  end

  def link_three
    a("/#{@place}?foo=bar", Rs(@place, :one, :foo => :bar))
  end

  def inspect_parameters
    request.params.inspect
  end

  def args
    @params.map{|arg| "<span>#{arg}</span>"}.join(' ')
  end
end

Ramaze.start
