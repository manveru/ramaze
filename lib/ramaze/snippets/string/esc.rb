require 'cgi'
require 'uri'

class String

  # String#escape is an extensible escaping mechanism for string.  currently
  # it suports
  #   '<div>foo bar</div>'.esc(:html)
  #   'foo bar'.esc(:uri)
  #   'foo bar'.esc(:cgi)

  def escape which = :html
    case which
    when :html
      ::CGI.escapeHTML(self)
    when :cgi
      ::CGI.escape(self)
    when :uri
      ::URI.escape(self)
    when :sql
      Ramaze::deprecated("String#escape(:sql)")
      gsub(%r/'/, "''")
    else
      raise ArgumentError, "do not know how to escape '#{ which }'"
    end
  end

  alias_method 'esc', 'escape'
end
