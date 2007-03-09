#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Kernel
  unless defined?(pretty_inspect)
    # returns a pretty printed object as a string.
    def pretty_inspect
      PP.pp(self, '')
    end
  end
end
