#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class String
  # A convenient way to do File.join
  # Usage:
  #   'a' / 'b' # => 'a/b'
  def / obj
    File.join(self, obj.to_s)
  end
end

class Symbol
  # A convenient way to do File.join
  # Usage:
  #   :dir/:file # => 'dir/file'
  def / obj
    self.to_s / obj
  end
end
