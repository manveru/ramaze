#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Extensions for Struct

class Symbol
  undef_method :to_int
end

class Struct

  # Example:
  #  Point = Struct.new(:x, :y)
  #  point = Point.new(15, 10)
  #  point.values_at(:y, :x)
  #  # => [10, 15]
  #  point.values_at(0, 1)
  #  # => [15, 10]

  def values_at(*keys)
    if keys.all?{|key| key.respond_to?(:to_int) }
      keys.map{|key| values[key.to_int] }
    else
      keys.map{|k| self[k.to_sym] }
    end
  end
end
