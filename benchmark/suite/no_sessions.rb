require 'ramaze'

class MainController < Ramaze::Controller
  def index
    "Hello, World!"
  end
end

Ramaze.middleware!(:live){|m| m.run(Ramaze::AppMap) }
Ramaze.options.mode = :live
Ramaze::Log.loggers.clear
