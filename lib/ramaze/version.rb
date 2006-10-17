module Ramaze #:nodoc:
  module Version #:nodoc:
    MAJOR = 0
    MINOR = 0
    TINY  = 1

    STRING = [MAJOR, MINOR, TINY].join('.')
  end

  VERSION = Version::STRING
end
