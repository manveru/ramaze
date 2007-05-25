#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Extensions for Struct

class Struct

  # Point = Struct.new(:x, :y)
  # point = Point.new(15, 10)
  # point.values_at(:y, :x)
  # # => [10, 15]

  def values_at(*keys)
    keys.map{|k| self[k.to_sym] }
  end
end
