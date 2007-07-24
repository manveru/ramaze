#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'syslog'

module Ramaze

  # Informer for Syslog from rubys standard-library.

  class Syslog
    include ::Syslog

    # opens syslog

    def initialize
      open unless ::Syslog.opened?
    end

    # alias for default syslog methods so they match ramaze
    alias error err
    alias warn warning

    # just sends all messages received to ::Syslog
    def inform(tag, *args)
      self.__send__(tag, *args)
    end

    public :error, :warn

    # Has to call the modules singleton-method.
    def inspect
      ::Syslog.inspect
    end
  end
end
