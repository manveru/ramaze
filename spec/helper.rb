if caller_line = caller.grep(%r!spec/ramaze/!).first
  caller_file = caller_line.split(':', 2).first
  caller_root = File.dirname(caller_file)
  $0 = caller_file
end

require File.expand_path(File.join(File.dirname(__FILE__), "../lib/ramaze"))
require 'ramaze/spec'

Ramaze.options.roots = [caller_root]
