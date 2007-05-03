#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

# TODO:
# implement the amrita2 example, man, this engine is awkward :P

class MainController < Controller
  trait :engine => Template::Amrita2
  trait :template_root => (File.dirname(__FILE__)/'template')

  def index
    %{ #{Rs()} | #{Rs(:internal)} | #{Rs(:external)} }
  end

  def title
    "The #@action Template for Amrita2"
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

Ramaze.start
