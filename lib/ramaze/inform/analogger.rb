#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'swiftcore/Analogger/Client'

module Ramaze

  class Analogger < ::Swiftcore::Analogger::Client
    include Informing

    trait :name => 'walrus'
    trait :host => '127.0.0.1'
    trait :port => 6766

    def initialize(name = class_trait[:name], host = class_trait[:host], port = class_trait[:port])
      super
    end

    def inform(tag, *args)
      log(tag, args.join("\n"))
    end
  end
end
