module Kernel
  unless defined?(pretty_inspect)
    # returns a pretty printed object as a string.
    def pretty_inspect
      PP.pp(self, '')
    end
  end
end
