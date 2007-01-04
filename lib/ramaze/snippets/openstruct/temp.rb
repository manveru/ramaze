#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
class OpenStruct
  def temp hash
    self.new(@table.merge(hash))
  end
end
