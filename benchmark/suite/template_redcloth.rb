require 'ramaze'

class MainController < Ramaze::Controller
  engine :RedCloth
  layout :layout

  def index
    @hello = "Hello, World!"
    '<% 10.times do %> %<%= @hello %>% <% end %>'
    %q[ html { body { 10.times { span @hello } } } ]
  end

  def layout
    '<html><body><%= @content %></body></html>'
  end
end
