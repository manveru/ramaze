require 'ramaze'

class MainController < Ramaze::Controller
  def index
    "Hello, World!"
  end
end

Ramaze::Inform.loggers = []
Ramaze::Global.sessions = false