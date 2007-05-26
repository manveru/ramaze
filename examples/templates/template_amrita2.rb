#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

# TODO:
#   - implement the amrita2 example, man, this engine is awkward :P

class MainController < Controller
  template_root File.expand_path((File.dirname(__FILE__)/'template'))
  trait :engine => Template::Amrita2

  def index
    %{ #{A(Rs())} | #{Rs(:internal)} | #{Rs(:external)} }
  end

  def title
    "The external Template for Amrita2"
  end

  def link_home
    A('Home', :href => '/')
  end

  def link_one
    A('/external/one', :href => Rs(:external, :one))
  end

  def link_two
    A("/external/one/two/three", :href => Rs(:external, :one, :two, :three))
  end

  def link_three
    A("/external?foo=bar", :href => Rs(:external, :one, :foo => :bar))
  end

  def inspect_parameters
    request.params.inspect
  end

  def args
    @params.map{|arg| "<span>#{arg}</span>"}.join(' ')
  end
end

Ramaze.start
