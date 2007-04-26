#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  class NotificationHub

    trait :loggers => {
      Informer => Informer.trait[:tags]
    }

    def initialize(loggers)
      @loggers = {}
      loggers.each do |logger, types|
        @loggers[logger.startup] = types.map! {|t| t.to_sym }
      end
    end

    def log(type, *message)
      @loggers.each do |logger, types|
        logger.__send__(type, message) if types.include?(type)
      end
    end

    Informer.trait[:tags].each do |meth,foo|
      define_method(meth) do |*args|
        log(meth, args.join("\n"))
      end

      define_method("#{meth}?") do |*args|
        inform_tag?(meth)
      end
    end

    # Webrick

    def <<(*args)
      log(:debug, args.join("\n"))
    end

    class << self
      def startup
        @instance ||= new(trait[:loggers])
      end
    end

    def inform_tag?(tag)
      @loggers.values.flatte.include?(tag.to_sym)
    end

  end

end
