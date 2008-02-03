require 'ramaze'

class MainController < Ramaze::Controller
  engine :Amrita2

  def index
    @data = {:hello => "Hello, World!"}
    '<html><body><% 10.times do %><span><<:hello>></span><% end %></body></html>'
  end
end
