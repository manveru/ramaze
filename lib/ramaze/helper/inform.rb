#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # Easy access to Log

  module LogHelper

    private

    # The various (default) tags you can use are:
    #
    # :info  - just outputs whatever you give to it without modification.
    # :debug - applies #inspect to everything you pass
    # :error - can take normal strings or exception-objects
    #
    #
    # Usage:
    #
    #   inform :info, 'proceeding as planned'
    #   # [2007-04-04 23:38:39] INFO   proceeding as planned
    #
    #   inform :debug, [1,2,3]
    #   # [2007-04-04 23:38:39] DEBUG  [1, 2, 3]
    #
    #   inform :error, 'something bad happened'
    #   # [2007-04-04 23:38:39] ERROR  something bad happened
    #
    #   inform :error, exception
    #   # [2007-04-04 23:40:59] ERROR  #<RuntimeError: Some exception>
    #   # [2007-04-04 23:40:59] ERROR  hello.rb:23:in `index'
    #   # ... rest of backtrace ...

    def inform tag, *args
      Log.send(tag, *args)
    end
  end
end
