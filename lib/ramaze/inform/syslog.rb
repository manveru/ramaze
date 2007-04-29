#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'syslog'

module Ramaze
  class Syslog
    include ::Syslog

    def initialize
      open unless ::Syslog.opened?
    end

    alias error err
    alias warn warning

    def inform(tag, *args)
      self.__send__(tag, *args)
    end

    public :error, :warn

    def inspect
      ::Syslog.inspect
    end
  end
end
