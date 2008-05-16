#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Extensions for Struct

class Struct
  undef values_at

  # Example:
  #  Point = Struct.new(:x, :y)
  #  point = Point.new(15, 10)
  #  point.values_at(:y, :x)
  #  # => [10, 15]
  #  point.values_at(0, 1)
  #  # => [15, 10]
  #  point.values_at(0..1)
  #  # => [15, 10]

  def values_at(*keys)
    if keys.all?{|key| key.respond_to?(:to_int) and not key.is_a?(Symbol) }
      keys.map{|key| values[key.to_int] }
    else
      out = []

      keys.each do |key|
        case key
        when Range
          key.each do |r|
            out << self[r]
          end
        else
          out << self[key]
        end
      end

      out
    end
  end
end
