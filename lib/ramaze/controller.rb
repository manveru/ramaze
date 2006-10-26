module Ramaze
  module Controller
    def request
      Thread.current[:request]
    end

    def response
      Thread.current[:response]
    end

    def session
      Thread.current[:session]
    end
  end
end
