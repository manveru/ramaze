require 'rubygems'
require 'ramaze'

class MainController < Ramaze::Controller
  engine :Remarkably

  helper :remarkably

  def index
    %{ #{a('Home', :href => r(:/) )} | #{a(:internal,:href => r(:internal) )} | #{a(:external, :href => r(:external) )} }
  end

  def internal *args
    @place = :internal
    html do
      head do
        title "Template::Remarkably internal"
      end
      body do
        h1 "The #@place Template for Remarkably"
        a("Home", :href => r(:/))
        P do
          text "Here you can pass some stuff if you like, parameters are just passed like this:"
          br
          a("#@place/one", :href => r( @place, :one))
          br
          a("#@place/one/two/three", :href => r( @place, :one, :two, :three))
          br
          a("#@place/one?foo=bar", :href => r( @place, :one, :foo => :bar))
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

Ramaze.start :file => __FILE__
