#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/trinity/request'
require 'ramaze/trinity/response'
require 'ramaze/trinity/session'

module Ramaze

  # The module to be included into the Controller it basically just provides
  # #request, #response and #session, each accessing Thread.current to
  # retrieve the demanded object

  module Trinity
    private

    # same as
    #   Thread.current[:request]

    def request
      Request.current
    end

    # same as
    #   Thread.current[:response]

    def response
      Response.current
    end

    # same as
    #   Thread.current[:session]

    def session
      Session.current
    end
  end
end
