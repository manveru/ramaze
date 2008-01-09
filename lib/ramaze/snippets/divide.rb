#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# A convenient way to do File.join
#
# Example:
#   'a' / 'b'                      # -> 'a/b'
#   File.dirname(__FILE__) / 'bar' # -> "ramaze/snippets/string/bar"

class String
  def / obj
    File.join(self, obj.to_s)
  end
end

class Symbol
  def / obj
    self.to_s / obj
  end
end