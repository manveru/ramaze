#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # Gives you back the file, line and method of the caller number i
  # Example:
  #   Ramaze.caller_info(1)
  #   # => ['/usr/lib/ruby/1.8/irb/workspace.rb', '52', 'irb_binding']

  def self.caller_info(i = 1)
    file, line, meth = caller[i].scan(/(.*?):(\d+):in `(.*?)'/).first
  end
end
