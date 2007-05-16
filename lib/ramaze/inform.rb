#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/inform/informing'
require 'ramaze/inform/hub'
require 'ramaze/inform/informer'

module Ramaze
  autoload :Analogger, "ramaze/inform/analogger.rb"
  autoload :Syslog,    "ramaze/inform/syslog.rb"
  autoload :Growl,     "ramaze/inform/growl.rb"
  autoload :Xosd,      "ramaze/inform/xosd.rb"

  unless defined?(Inform)
    Inform = LogHub.new(Informer)
  end
end
