module Ramaze
  module Controller
    def request
      Thread.current[:request]
    end

    def session
      Thread.current[:session]
    end
  end
end
