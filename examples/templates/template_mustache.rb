require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :Mustache

  def index
    @home     = a('Home',:/)
    @internal = a(:internal)
    @external = a(:external)

    %{ {{{home}}} | {{{internal}}} | {{{external}}} }
  end

  def internal(*args)
    set_mustache_variables(:internal, *args)

    %q{
<html>
  <head>
    <title>Template::Mustache internal</title>
  </head>
  <body>
  <h1>{{header}}</h1>
    {{{link_home}}}
    <p>
      Here you can pass some stuff if you like, parameters are just passed like this:<br />
      {{{link_one}}}<br />
      {{{link_two}}}<br />
      {{{link_three}}}
    </p>
    <div>
      The arguments you have passed to this action are:
      {{#args_empty}}
        none
      {{/args_empty}}
      {{#not_empty}}
        {{#args}}
          <span>{{arg}}</span>
        {{/args}}
      {{/not_empty}}
    </div>
    <div>
      {{params}}
    </div>
  </body>
</html>
    }
  end

  def external *args
    set_mustache_variables(:external, *args)
  end

  private

  def set_mustache_variables(place, *args)
    @header     = "The #{place} Template for Mustache"
    @link_home  = a('Home', :/)
    @link_one   = a("#{place}/one")
    @link_two   = a("#{place}/one/two/three")
    @link_three = a("#{place}?foo=Bar")
    @args       = args.map { |arg| {:arg => arg} }
    @args_empty = args.empty?
    @not_empty  = !@args_empty
    @params     = request.params.inspect
  end
end

Ramaze.start :file => __FILE__
