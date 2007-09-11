class Array
  def put_within(object, constrain)
    pre, post = constrain.values_at(:after, :before)

    unless rindex(post) - index(pre) == 1
      raise ArgumentError, "Too many elements within constrain"
    end

    put_after(pre, object)
  end

  def put_after(element, object)
    raise ArgumentError, "The given element doesn't exist" unless include?(element)
    self[index(element) + 1, 0] = object
  end

  def put_before(element, object)
    raise ArgumentError, "The given element doesn't exist" unless include?(element)
    self[rindex(element), 0] = object
  end
end
