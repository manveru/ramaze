#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/inform/informing'
require 'ramaze/inform/hub'
require 'ramaze/inform/informer'

begin
  require 'win32console' if RUBY_PLATFORM =~ /win32/i
rescue LoadError => ex
  puts ex
  puts "For nice colors on windows, please `gem install win32console`"
  Ramaze::Informer.trait[:colorize] = false
end

module Ramaze
  autoload :Analogger, "ramaze/inform/analogger.rb"
  autoload :Knotify,   "ramaze/inform/knotify.rb"
  autoload :Syslog,    "ramaze/inform/syslog.rb"
  autoload :Growl,     "ramaze/inform/growl.rb"
  autoload :Xosd,      "ramaze/inform/xosd.rb"

  unless defined?(Inform)
    Inform = LogHub.new(Informer)
  end
end
