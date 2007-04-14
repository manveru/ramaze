#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'swiftcore/Analogger/Client'

module Ramaze

  class Analogger < ::Swiftcore::Analogger::Client

    trait :name => 'walrus'
    trait :host => '127.0.0.1'
    trait :port => 6766

    Informer.trait[:tags].each do |meth|
      define_method(meth) do |*args|
        log(meth, args.join("\n")) if inform_tag?(meth)
      end
    end

    class << self
      def startup
        name, host, port = ancestral_trait.vlaues_at(:name, :host, :port))
        Analogger.new(name, host, port)
      end
    end

  private

    def inform_tag?(inform_tag)
      Ramaze::Global.inform_tags.include?(inform_tag)
    end
  end
end
