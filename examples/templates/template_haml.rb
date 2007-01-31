#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

class MainController < Template::Haml
  def index
    %{ #{link self.class} | #{link self.class, :internal} | #{link self.class, :external} }
  end

  def internal *args
    @args = args
    @title = "The #{@action} Template for Haml"

    %{
    %html
      %head
        %title= "Template::Haml internal"
      %body
        %h1= @title
        = link( R(:/), :title => 'Home')
        %p
          = "Here you can pass some stuff if you like, parameters are just passed like this:"
          %br/
          = link( R(self, @action, :one), :title => 'internal/one') 
          %br/
          = link( R(self, @action, :one, :two, :three), :title => 'internal/one/two/three') 
          %br/
          = link( R(self, @action, :one, :foo => :bar), :title => 'internal/one?foo=bar') 
        %div= "The arguments you have passed to this action are:"
          - if @args.empty?
            = "none"
          - else
            -  @args.each do |arg|
               %span= arg
        %div= request.params.inspect
    }
  end

  def external *args
    @title = "The #{@action} Template for Haml"
    @args = args
  end
end

Ramaze.start
