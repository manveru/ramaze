module Kernel
  def rescue_require(sym, message = nil)
    require sym
  rescue LoadError
    puts message if message
  end
end
