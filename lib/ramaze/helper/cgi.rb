#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module CgiHelper
    private

    def escape(*args)
      CGI.escape(*args)
    end

    def unescape(*args)
      CGI.escape(*args)
    end
  end
end
