#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

class MainController < Controller
  trait :engine => Template::Markaby
  trait :map => '/'

  helper :markaby

  def index
    %{ #{Rlink self.class} | #{Rlink self.class, :internal} | #{Rlink self.class, :external} }
  end

  def internal *args
    @args = args
    @request = request
    mab do
      html do
        head do
          title "Template::Markaby internal"
        end
        body do
          h1 "The #{@action} Template for Markaby"
          a("Home", :href => R(:/))
          p do
            text "Here you can pass some stuff if you like, parameters are just passed like this:"
            br
            a("external/one", :href => Rs(@action, :one))
            br
            a("external/one/two/three", :href => Rs(@action, :one, :two, :three))
            br
            a("external/one?foo=bar", :href => Rs(@action, :one, :foo => :bar))
            br
          end
          div do
            text "The arguments you have passed to this action are:" 
            if @args.empty?
              "none"
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
  end
end

Ramaze.start
