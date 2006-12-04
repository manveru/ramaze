require 'ramaze/trinity/request'
require 'ramaze/trinity/response'
require 'ramaze/trinity/session'

module Ramaze
  module Trinity
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
