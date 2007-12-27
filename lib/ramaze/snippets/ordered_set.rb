#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.join(File.dirname(__FILE__), 'blankslate')

class OrderedSet < BlankSlate
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
    @set.compact! if meth == :[]=
  end
end
