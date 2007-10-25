class OrderedSet
  instance_methods.each { |m| undef_method m unless m =~ /^__/ }

  def initialize(*args)
    @set = *args
    @set ||= []
    @set = [@set] unless Array === @set
    @set.uniq!
  end

  def method_missing(meth, *args, &block)
    case meth.to_s
    when /push|unshift|\<\</
      @set.delete *args
    when '[]='
      @set.map! do |e|
        if Array === args.last
          args.last.include?(e) ? nil : e
        else
          args.last == e ? nil : e
        end
      end
    end
    @set.__send__(meth, *args, &block)
  ensure
    @set.delete nil
  end
end