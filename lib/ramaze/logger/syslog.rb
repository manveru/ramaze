#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'syslog'

module Syslog
  class << self
    alias_method :error, :err
    alias_method :warn, :warning

    alias_method :startup, :open
  end
end

Ramaze::Syslog = Syslog unless defined?(Ramaze::Syslog)
