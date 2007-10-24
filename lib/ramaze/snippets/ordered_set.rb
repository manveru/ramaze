class OrderedSet
  instance_methods.each { |m| undef_method m unless m =~ /^__/ }

  def initialize(*args)
    @set = *args
    @set ||= []
    @set.uniq!
  end

  def method_missing(meth, *args, &block)
    @set.__send__(meth, *args, &block)
  ensure
    @set.uniq!
  end
end