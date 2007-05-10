#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Informer
    include Informing

    attr_accessor :colorize, :out

    # parameter for Time.now.strftime
    trait :timestamp => "%Y-%m-%d %H:%M:%S"

    # This is how the final output is arranged.
    trait :format => "[%time] %prefix  %text"

    # Which tag should be in what color
    trait :colors => {
      :info  => :green,
      :debug => :yellow,
      :warn  => :red,
      :error => :red,
    }

    def initialize(out = $stdout, colorize = nil)
      @out =
        case out
        when STDOUT, :stdout, 'stdout'
          $stdout
        when STDERR, :stderr, 'stderr'
          $stderr
        when IO
          out
        else
          if out.respond_to?(:puts)
            out
          else
            colorize = false
            File.open(out.to_s, 'ab+')
          end
        end

      @colorize = @out.tty? rescue false if colorize.nil?
    end

    def shutdown
      if @out.respond_to?(:close)
        Inform.debug("close, #{@out.inspect}")
        @out.close
      end
    end

    def inform tag, *messages
      return if closed?
      messages.flatten!

      prefix = tag.to_s.upcase.ljust(5)

      if @colorize
        color = class_trait[:colors][tag] ||= :white
        prefix.replace prefix.send(color)
      end

      messages.each do |message|
        @out.puts(log_interpolate(prefix, message))
      end

      @out.flush if @out.respond_to?(:flush)
    end

    def log_interpolate prefix, text, time = timestamp
      message = class_trait[:format].dup

      vars = { '%time' => time, '%prefix' => prefix, '%text' => text }
      vars.each{|from, to| message.gsub!(from, to) }

      message
    end

    # This uses Global.inform_timestamp or a date in the format of
    #   %Y-%m-%d %H:%M:%S
    #   # => "2007-01-19 21:09:32"

    def timestamp
      mask = class_trait[:timestamp]
      Time.now.strftime(mask || "%Y-%m-%d %H:%M:%S")
    end

    def closed?
      @out.respond_to?(:closed?) and @out.closed?
    end
  end
end
