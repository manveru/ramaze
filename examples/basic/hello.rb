require 'rubygems'
require 'ramaze'

# Start this example with `ruby hello.rb`.
# After startup you will be able to access it at http://localhost:7000/
# This should output "Hello, World!" in your browser.

class MainController < Ramaze::Controller
  def index
    "Hello, World!"
  end
end

Ramaze.start
