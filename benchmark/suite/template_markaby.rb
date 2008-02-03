require 'ramaze'

class MainController < Ramaze::Controller
  engine :Markaby

  def index
    @hello = "Hello, World!"
    %q[ html { body { 10.times { span @hello } } } ]
  end
end
