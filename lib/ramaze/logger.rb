#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  autoload :GlobalInformer, "ramaze/logger/global_informer.rb"
  autoload :Analogger,      "ramaze/logger/analogger.rb"
  autoload :Informer,       "ramaze/logger/global_informer.rb"
  autoload :Inform,         "ramaze/logger/inform.rb"
  autoload :Syslog,         "ramaze/logger/syslog.rb"
end
