#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class MainController < Controller
  # the index action is called automatically when no other action is specified
  def index
    @welcome = "Welcome to Ramaze!"
  end
  def notemplate
    "there is no template associated with this action"
  end
end
