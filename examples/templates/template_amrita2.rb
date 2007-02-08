#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

# TODO:
# implement the amrita2 example, man, this engine is awkward :P

class MainController < Template::Amrita2
  def index
    %{ #{link self.class} | #{link self.class, :internal} | #{link self.class, :external} }
  end

  def title
    "The #{@action} Template for Ramaze"
  end

  def link_home
    link :/, :title => 'Home'
  end

  def link_one
      link self, @action, :one, :title => "#@action/one"
  end

  def link_two
      link self, @action, :one, :two, :three, :title => "#@action/one/two/three"
  end

  def link_three
      link self, @action, :one, :foo => :bar, :title => "#@action?foo=bar"
  end

  def inspect_parameters
    request.params.inspect
  end

  def args
    @params.map{|arg| "<span>#{arg}</span>"}.join(' ')
  end
end

start
