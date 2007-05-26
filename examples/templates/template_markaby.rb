#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

class MainController < Controller
  template_root File.expand_path((File.dirname(__FILE__)/'template'))
  trait :engine => Template::Markaby

  helper :markaby

  def index
    %{ #{A 'Home', :href => :/} | #{A(:internal)} | #{A(:external)} }
  end

  def internal *args
    options = {:place => :internal, :action => 'internal',
      :args => args, :request => request, :this => self}
    mab options do
      html do
        head do
          title "Template::Markaby #@place"
        end
        body do
          h1 "The #@place Template for Markaby"
          a("Home", :href => R(@this))
          p do
            text "Here you can pass some stuff if you like, parameters are just passed like this:"
            br
            a("#@place/one", :href => R(@this, @place, :one))
            br
            a("#@place/one/two/three", :href => R(@this, @place, :one, :two, :three))
            br
            a("#@place/one?foo=bar", :href => R(@this, @place, :one, :foo => :bar))
            br
          end
          div do
            text "The arguments you have passed to this action are:" 
            if @args.empty?
              text "none"
            else
              args.each do |arg|
                span arg
              end
            end
          end
          div @request.params.inspect
        end
      end
    end.to_s
  end

  def external *args
    @args = args
    @request = request
    @place = :external
  end
end

Ramaze.start
