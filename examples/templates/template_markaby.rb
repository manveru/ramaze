#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

class MainController < Controller
  trait :engine => Template::Markaby
  def index
    %{ #{link self.class} | #{link self.class, :internal} | #{link self.class, :external} }
  end

  def internal *args
    @args = args
    mab do
      html do
        head do
          title "Template::Markaby internal"
        end
        body do
          h1 "The #{@action} Template for Markaby"
          a("Home", :href => R(:/))
          p("Here you can pass some stuff if you like, parameters are just passed like this:") do
            br
            a("external/one", :href => R(self, @action, :one))
            br
            a("external/one/two/three", :href => R(self, @action, :one, :two, :three))
            br
            a("external/one?foo=bar", :href => R(self, @action, :one, :foo => :bar))
            br
          end
          div "The arguments you have passed to this action are:" do
            if @args.empty?
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
    end.to_s
  end

  def external *args
    @args = args
  end
end

Ramaze.start
