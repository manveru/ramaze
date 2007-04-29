#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class LogHub
    include Informing

    attr_accessor :loggers

    def initialize(*loggers)
      @loggers = loggers
      @loggers.map! do |logger|
        if logger.respond_to?(:new)
          logger.new
        else
          logger
        end
      end
    end

    def inform(tag, *args)
      (@loggers - self).each do |logger|
        logger.inform(tag, *args)
      end
    end
  end
end
