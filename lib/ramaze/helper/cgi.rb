#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # Shortcuts to some CGI methods

  module CgiHelper
    private

    # shortcut for CGI.escape

    def url_encode(*args)
      CGI.escape(*args)
    end

    # shortcut for CGI.unescape

    def url_decode(*args)
      CGI.unescape(*args)
    end

    # shortcut for CGI.escapeHTML

    def html_escape(string)
      CGI.escapeHTML(string)
    end

    # shortcut for CGI.unescapeHTML

    def html_unescape(string)
      CGI.unescapeHTML(string)
    end

    # safely escape all HTML and code
    def c(string)
      CGI.escapeHTML(string).gsub(/#/, '&#35;')
    end

    # one-letter versions help in case like #{h foo.inspect}
    # ERb/ERuby/Rails compatible
    alias u url_encode
    alias h c
  end
end
