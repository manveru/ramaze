#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  class NotificationHub
    trait :loggers => Set.new([Informer])
    trait :instances => {}

    def method_missing(*args)
      collect_loggers.each do |logger, instance|
        instance.__send__(*args)
      end
    rescue Object => ex
      puts ex
      puts ex.backtrace
    end

    def collect_loggers
      t = ancestral_trait

      t[:instances].delete_if{|k,v| not t[:loggers].include?(k)}

      (t[:loggers].to_a - t[:instances].keys).each do |logger|
        t[:instances][logger] = logger.startup
      end

      t[:instances]
    end

    def self.startup
      self.new
    end
  end
end
