#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

class MainController < Ramaze::Controller
  template_root File.expand_path((File.dirname(__FILE__)/'template'))
  trait :engine => Ramaze::Template::Haml

  def index
    %{ #{link Rs()} | #{link Rs(:internal)} | #{link Rs(:external)} }
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
    = Rs(:/, :title => 'Home')
    %p
      Here you can pass some stuff if you like, parameters are just passed like this:
      %br/
      = link( Rs(@place, :one), :title => "/#@place/one")
      %br/
      = link( Rs(@place, :one, :two, :three), :title => "/#@place/one/two/three")
      %br/
      = link( Rs(@place, :one, :foo => :bar), :title => "/#@place/one?foo=bar")
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

Ramaze.start
