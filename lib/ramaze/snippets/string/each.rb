#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class String
  alias each each_line unless ''.respond_to?(:each)
end
