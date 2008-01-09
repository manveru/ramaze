#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Extensions for String

class String
  alias each each_line unless ''.respond_to?(:each)
end
