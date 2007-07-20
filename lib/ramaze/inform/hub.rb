#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'set'

module Ramaze

  # Bundles different informer instances and sends incoming messages to each.
  # This is the default with Informer as only member.

  class LogHub
    include Informing

    attr_accessor :loggers
    attr_accessor :ignored_tags

    def initialize(*loggers)
      @loggers = loggers
      @ignored_tags = Set.new
      @loggers.map! do |logger|
        next(nil) if logger == self
        logger.is_a?(Class) ? logger.new : logger
      end
      @loggers.uniq!
      @loggers.compact!
    end

    # integration to Informing

    def inform(tag, *args)
      return if @ignored_tags.include?(tag)
      @loggers.each do |logger|
        logger.inform(tag, *args)
      end
    end
  end
end
