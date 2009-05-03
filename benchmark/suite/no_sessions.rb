class MainController < Ramaze::Controller
  def index
    "Hello, World!"
  end
end

Ramaze.middleware!(:nosessions){|m| m.run(Ramaze::AppMap) }
Ramaze.options.mode = :nosessions
Ramaze::Log.loggers.clear
