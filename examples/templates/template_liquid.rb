#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

class MainController < Controller
  trait :engine => Template::Liquid
  def index
    %{ #{link self.class} | #{link self.class, :internal} | #{link self.class, :external} }
  end

  def liquid_hash(*args)
    {
      'header'     => "The #{@action} Template",
      'link_home'  => link( :/, :title => 'Home'),
      'link_one'   => link(self, @action, :one, :title => "#@action/one"),
      'link_two'   => link(self, @action, :one, :two, :three, :title => "#@action/one/two/three"),
      'link_three' => link(self, @action, :one, :foo => :bar, :title => "#@action?foo=Bar"),
      'args'       => args,
      'args_empty' => args.empty?,
      'params'     => request.params.inspect
    }
  end


  def internal *args
    @hash = liquid_hash(*args)
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
    @hash = liquid_hash(*args)
  end
end
