class OrderedSet
  instance_methods.each { |m| undef_method m unless m =~ /^__/ }

  def initialize(a)
    @a = a
    @a.uniq!
  end

  def method_missing(meth, *args, &block)
    @a.__send__(meth, *args, &block)
  ensure
    @a.uniq! if meth.to_s =~ /push|\<\<|unshift/
  end
end