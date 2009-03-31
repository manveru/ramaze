require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :Haml

  def index
    %{#{a('Home',:/)} | #{a(:internal)} | #{a(:external)}}
  end

  def internal *args
    @args = args
    @place = :internal
    @title = "The #@place Template for Haml"

    %q{
%html
  %head
    %title= "Template::Haml #@place"
  %body
    %h1= @title
    = a('Home',:/)
    %p
      Here you can pass some stuff if you like, parameters are just passed like this:
      %br/
      = a("#@place/one")
      %br/
      = a("#@place/one/two/three")
      %br/
      = a("#@place/one?foo=bar")
    %div
      The arguments you have passed to this action are:
      - if @args.empty?
        none
      - else
        - @args.each do |arg|
          %span= arg
    %div= request.params.inspect
    }
  end

  def external *args
    @args = args
    @place = :external
    @title = "The #@place Template for Haml"
  end
end

Ramaze.start :file => __FILE__
