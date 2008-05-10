#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # Shortcuts to some CGI methods

  module Helper::CGI
    # shortcut for CGI.escape

    def url_encode(*args)
      ::CGI.escape(*args.map{|arg| arg.to_s})
    end

    # shortcut for CGI.unescape

    def url_decode(*args)
      ::CGI.unescape(*args.map{|arg| arg.to_s})
    end

    # shortcut for CGI.escapeHTML

    def html_escape(string)
      ::CGI.escapeHTML(string.to_s)
    end

    # shortcut for CGI.unescapeHTML

    def html_unescape(string)
      ::CGI.unescapeHTML(string.to_s)
    end

    # safely escape all HTML and code
    def h(string)
      ::CGI.escapeHTML(string.to_s).gsub(/#/, '&#35;')
    end

    def c(string)
      Ramaze::deprecated("Helper::CGI#c", "Helper::CGI#h")
      h(string)
    end

    # one-letter versions help in case like #{h foo.inspect}
    # ERb/ERuby/Rails compatible
    alias u url_encode
  end
end
