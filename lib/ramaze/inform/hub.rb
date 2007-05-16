#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class LogHub
    include Informing

    attr_accessor :loggers

    def initialize(*loggers)
      @loggers = loggers
      @loggers.map! do |logger|
        next(nil) if logger == self
        logger.is_a?(Class) ? logger.new : logger
      end
      @loggers.uniq!
      @loggers.compact!
    end

    def inform(tag, *args)
      @loggers.each do |logger|
        logger.inform(tag, *args)
      end
    end
  end
end
