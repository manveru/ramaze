require 'ramaze'

class Ramaze::Template::NoTemplate < Ramaze::Template::Template
  def self.transform action
    render_method(action)
  end
end

class MainController < Ramaze::Controller
  trait :engine => Ramaze::Template::NoTemplate
  def index
    "Hello, World!"
  end
end