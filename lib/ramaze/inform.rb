#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/inform/informing'

module Ramaze
  autoload :Analogger, "ramaze/inform/analogger.rb"
  autoload :Informer,  "ramaze/inform/informer.rb"
  autoload :Syslog,    "ramaze/inform/syslog.rb"
  autoload :Growl,     "ramaze/inform/growl.rb"
  autoload :Xosd,      "ramaze/inform/xosd.rb"
  autoload :LogHub,    "ramaze/inform/hub.rb"
end
