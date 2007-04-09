#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class String
  unless defined?(each)
    def each(&block)
      each_line(&block)
    end
  end
end
