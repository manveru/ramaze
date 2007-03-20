#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# This chunk of code redefines the #method method of Kernel to act more
# dynamic.

module Kernel
  alias_method :method_get, :method unless defined? method_get

  # get the object of the method you are currently in or any
  # other out of the backtrace, as long as it is in the same
  # instance and retrievable via method_get (which is the old #method).
  #
  #   class Foo
  #     def bar
  #       method
  #     end
  #   end
  #
  #   Foo.new.bar #=> #<Method: Foo#bar>

  def method(n = 0)
    return method_get(n) unless n.is_a? Integer
    method_get caller.to_s.scan(/`(.*?)'/)[n].first rescue nil
  end
end
