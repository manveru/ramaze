#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze'

include Ramaze

# This is named MainController to automagically map it to '/'
#   Global.mapping['/'] => MainController
# would do the same thing.
# you can access it now with http://localhost:7000/
# This should output
# Hello, World!
# in your browser

class MainController < Template::Ramaze
  def index
    "Hello, World!"
  end
end
