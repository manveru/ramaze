#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'swiftcore/Analogger/Client'
require 'ramaze/logger/inform'

module Ramaze

  class Analogger < ::Swiftcore::Analogger::Client

    include Informing

    def initialize(name = 'walrus', host = '127.0.0.1', port = 6766)
      super
    end

    def inform(tag, *args)
      log(tag, args.join("\n"))
    end
  end
end
