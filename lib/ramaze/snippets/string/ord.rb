#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Extensions for String

class String
  unless method_defined?(:ord)

    # compatibility with Ruby 1.9

    def ord
      self[0]
    end
  end
end
