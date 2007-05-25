#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # Shortcuts to some CGI methods

  module CgiHelper
    private

    # shortcut for CGI.escape

    def escape(*args)
      CGI.escape(*args)
    end

    # shortcut for CGI.unescape

    def unescape(*args)
      CGI.escape(*args)
    end
  end
end
