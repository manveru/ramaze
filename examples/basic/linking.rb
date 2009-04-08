require 'rubygems'
require 'ramaze'

class LinkingController < Ramaze::Controller
  map '/'

  def index
    %{simple link <br/> <a href="#{r(:help)}">Help?</a>}
  end

  def new
    "something new!"
  end

  def help
    %{you have help <br/> <a href="#{LinkToController.r(:another)}">A Different Controller</a>}
  end

end

class LinkToController < Ramaze::Controller
  map '/link_to'

  def another
    %{<a href="#{LinkingController.r(:index)}">Back to Original Controller</a>}
  end
end

Ramaze.start
