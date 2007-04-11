#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'swiftcore/Analogger/Client'

module Ramaze

  class Analogger < ::Swiftcore::Analogger::Client

    [:warn, :debug, :info, :error].each do |meth|
      define_method(meth) do |*args|
        log(meth, args.join("\n")) if inform_tag?(meth)
      end
    end

  private
    def inform_tag?(inform_tag)
      Ramaze::Global.inform_tags.include?(inform_tag)
    end

  end

  Informer = Analogger.new('walrus','127.0.0.1','6766')

end
