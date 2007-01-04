#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Kernel
  def rescue_require(sym, message = nil)
    require sym
  rescue LoadError, RuntimeError
    puts message if message
  end
end
