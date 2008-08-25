# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout '/page'
  helper :xhtml
  engine :Ezamar
end

acquire __DIR__/"*.rb"
