=begin

# Title

Adding Kernel#self_method or Kernel#this_method


#  Abstract

 We all are used to self by now, but how to fetch the current method?
 My proposal is to add a method that returns either the name or just the object of the current method itself.


# Proposal

 This is a common problem, that often shows up while debugging method-calls and tracing them.
 The usual approach is to add a hack like that below, by (ab)using Kernel#caller.
 However, adding this method doesn't help the clarity of any program and is only a hack for something that self is doing already - providing a handle to itself.

# Analysis

# Example of usage

class A
  def a; method         end
  def b; method.name    end
  def c; method(:b)     end
  def d; B.send(method.name) end

  class << self
    def a; method         end
    def b; method.name    end
    def c; method(:b)     end
    def d; B.send(method.name) end
  end
end

class B
  def self.d; method end
end

a_class = A
a_object = A.new

[:a,:b,:c,:d].each do |m|
  puts "A.send(:#{m})"
  p a_class.send(m)
  puts "A.new.send(:#{m})"
  p a_object.send(m)
end

p method(:puts).name
p method(:p)

=end

module Kernel
  alias :method_get :method
  def method(n = 0)
    return method_get(n) unless n.is_a? Integer
    method_get caller.to_s.scan(/`(.*?)'/)[n].first rescue nil
  end
end

class Method
  def name
    #<Method: A.d>
    inspect.gsub(/#<Method: .*?[\.#](.*?)>/, '\1')
  end
end
