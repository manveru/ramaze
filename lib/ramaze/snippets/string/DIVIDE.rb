#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class String

  # A convinient way to do File.join
  #
  # Example:
  #   'a' / 'b'                      # -> 'a/b'
  #   File.dirname(__FILE__) / 'bar' # -> "ramaze/snippets/string/bar"

  def / obj
    File.join(self, obj.to_s)
  end
end

