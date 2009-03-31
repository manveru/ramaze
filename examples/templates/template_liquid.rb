require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :Liquid

  def index
    %{ {% anchor "Home" / %} |
       {% anchor "internal" internal %} |
       {% anchor "external" external %}}
  end

  def internal(*args)
    set_liquid_variables(:internal, *args)

    %q{
<html>
  <head>
    <title>Template::Liquid internal</title>
  </head>
  <body>
  <h1>{{header}}</h1>
    {{link_home}}
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      {{link_one}}<br />
      {{link_two}}<br />
      {{link_three}}
    </p>
    <div>
      The arguments you have passed to this action are:
      {% if args_empty %}
        none
      {% else %}
        {% for arg in args %}
          <span>{{arg}}</span>
        {% endfor %}
      {% endif %}
    </div>
    <div>
      {{params}}
    </div>
  </body>
</html>
    }
  end

  def external *args
    set_liquid_variables(:internal, *args)
  end

  private

  def set_liquid_variables(place, *args)
    @header = "The #{place} Template for Liquid"
    @link_home = a('Home', :/)
    @link_one = a("#{place}/one")
    @link_two = a("#{place}/one/two/three")
    @link_three = a("#{place}?foo=Bar")
    @args = args
    @args_empty = args.empty?
    @params = request.params.inspect
  end
end

Ramaze.start :file => __FILE__
