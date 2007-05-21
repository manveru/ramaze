#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

class MainController < Controller
  template_root File.expand_path((File.dirname(__FILE__)/'template'))
  trait :engine => Template::Remarkably

  include Remarkably

  def index
    %{ #{Rlink self.class} | #{Rlink self.class, :internal} | #{Rlink self.class, :external} }
  end

  def internal *args
    @place = :internal
    html do
      head do
        title "Template::Remarkably internal"
      end
      body do
        h1 "The #@place Template for Remarkably"
        a("Home", :href => R(:/))
        P do
          text "Here you can pass some stuff if you like, parameters are just passed like this:"
          br
          a("#@place/one", :href => Rs( @place, :one))
          br
          a("#@place/one/two/three", :href => Rs( @place, :one, :two, :three))
          br
          a("#@place/one?foo=bar", :href => Rs( @place, :one, :foo => :bar))
          br
        end
        div do
          text "The arguments you have passed to this action are:" 
          if args.empty?
            "none"
          else
            args.each do |arg|
              span arg
            end
          end
        end
        div request.params.inspect
      end
    end
  end

  def external *args
    @args = args
    @place = :external
    @request = request
  end
end

Ramaze.start
