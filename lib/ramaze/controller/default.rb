module Ramaze
  Log.debug "Default controller invoked"

  class DefaultController < Ramaze::Controller
    map '/'

    def lobster
      require 'rack/lobster'
      respond Rack::Lobster::LobsterString
    end
  end
end
