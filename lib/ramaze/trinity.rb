#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

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
