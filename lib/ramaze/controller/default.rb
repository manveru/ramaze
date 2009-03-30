module Ramaze
  Log.debug "Default controller invoked"

  class DefaultController < Ramaze::Controller
    map '/'
  end
end
