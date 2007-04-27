require 'ramaze/inform/informing'

module Ramaze
  autoload :Analogger, "ramaze/inform/analogger.rb"
  autoload :Informer,  "ramaze/inform/informer.rb"
  autoload :Syslog,    "ramaze/inform/syslog.rb"
  autoload :Growl,     "ramaze/inform/growl.rb"
  autoload :Xosd,      "ramaze/inform/xosd.rb"
  autoload :LogHub,    "ramaze/inform/hub.rb"
end

require 'ramaze/global'

module Ramaze
  # TODO: This is ugly, error-prone and actually
  #       no good idea at all, but works for the moment.

  Inform = Global.logger unless defined?(Inform)
end
