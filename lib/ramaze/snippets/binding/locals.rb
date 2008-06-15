class Binding

  # returns a hash of localvar/localvar-values from binding, useful for
  # template engines that do not accept bindings and force passing locals via
  # hash
  #   usage: x = 42; p binding.locals #=> {'x'=> 42}
  def locals
    Kernel::eval '
      local_variables.inject({}){|h,v| k = v.to_s; h.merge!(k => eval(k)) }
    ', self
  end

end
