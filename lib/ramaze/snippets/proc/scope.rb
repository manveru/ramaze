class Proc

  # returns a hash of localvar/localvar-values from proc, useful for template
  # engines that do not accept bindings/proc and force passing locals via
  # hash
  #   usage: x = 42; p Proc.new.locals #=> {'x'=> 42}
  def locals
    eval '
      local_variables.inject({}){|h,v| h.update v => eval(v)}
    ', self
  end

end
