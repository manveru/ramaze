class MainController < Ramaze::Controller
  engine :Etanni

  def index
    @hello = "Hello, World!"
    '<html><body><?r 10.times do ?><span>#{@hello}</span><?r end ?></body></html>'
  end
end
