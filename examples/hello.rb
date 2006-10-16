require 'ramaze'

include Ramaze

# This is named MainController to automagically map it to '/'
#   Global.mapping['/'] => MainController
# would do the same thing.
# you can access it now with http://localhost:7000/

class MainController < Template::Ramaze
  def index
    "Hello, World!"
  end
end
