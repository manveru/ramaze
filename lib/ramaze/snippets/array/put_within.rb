#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class Array

  #   a = [1, 2, 3]
  #   a.put_within(4, :after => 2, :before => 3)
  #   a # => [1, 2, 4, 3]

  def put_within(object, constrain)
    pre, post = constrain.values_at(:after, :before)

    unless rindex(post) - index(pre) == 1
      raise ArgumentError, "Too many elements within constrain"
    end

    put_after(pre, object)
  end

  #   a = [1, 2, 3]
  #   a.put_after(2, 4)
  #   a # => [1, 2, 4, 3]

  def put_after(element, object)
    raise ArgumentError, "The given element doesn't exist" unless include?(element)
    self[index(element) + 1, 0] = object
  end

  #   a = [1, 2, 3]
  #   a.put_before(2, 4)
  #   a # => [1, 4, 2, 3]

  def put_before(element, object)
    raise ArgumentError, "The given element doesn't exist" unless include?(element)
    self[rindex(element), 0] = object
  end
end
