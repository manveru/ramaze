class MainController < Ramaze::Controller
  engine :None

  def index
    "Hello, World!"
  end
end

Ramaze.middleware!(:bench){|m| m.run(Ramaze::AppMap) }
Ramaze.options.mode = :bench
Ramaze::Log.loggers.clear
