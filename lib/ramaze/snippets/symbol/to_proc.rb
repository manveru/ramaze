#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
class Symbol

  # the well-known #to_proc
  # creates a lambda that sends the symbol and any further arguments
  # to the object yielded.
  #   [1, 2, 3].map(&:to_s)    # => ['1', '2', '3']
  #   %w[a b c].map(&:to_sym)  # => [:a, :b, :c]

  def to_proc
    lambda{|o, *args| o.send(self, *args) }
  end
end
