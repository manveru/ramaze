#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze #:nodoc:
  module Version #:nodoc:
    MAJOR = 0
    MINOR = 3
    TINY  = 9.5

    STRING = [MAJOR, MINOR, TINY].join('.')
  end

  VERSION = Version::STRING
end
