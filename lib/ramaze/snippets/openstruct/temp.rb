#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Extensions for OpenStruct

class OpenStruct

  # create a new OpenStruct and fill it with a merge of the old @table and the passed hash

  def temp hash
    self.class.new(@table.merge(hash))
  end
end
