#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Kernel
  def silently
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end
