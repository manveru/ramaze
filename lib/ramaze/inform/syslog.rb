#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'syslog'

module Ramaze
  class Syslog
    include ::Syslog
    include Informing

    def initialize
      if File.writeable?('/dev/log')
        open
      else
        raise "Cannot open /dev/log - make sure you have the proper permissions"
      end
    end

    alias error err
    alias warn warning

    public :error, :warn
  end
end
