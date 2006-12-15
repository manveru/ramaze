#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # The central interface-tool for Ramaze, it just spits out all the things
  # you always wanted to tell your user but didn't dare to ;)
  #
  # Important to the Logger is especially Global.mode, which can be
  # one of:
  #  Global.mode = :benchmark # switch all logging on and bench requests
  #  Global.mode = :debug     # switch all logging on
  #  Global.mode = :stage     # switch on info- and errorlogging
  #  Global.mode = :live      # switch on errorlogging
  #  Global.mode = :silent    # switch off logging
  #
  #
  # It has a method called Logger#puts which uses per default Kernel#puts
  # and which is called by the central #log method (that in turn is used by
  # all the other logging-methods)
  #
  # Example of use:
  #   Logger.info "Hello, World!"
  #   include Logger
  #   info "Hello again"
  #
  #   begin
  #     raise StandardError, "Something gone wrong"
  #   rescue => ex
  #     error ex
  #   end
  #
  # So if you want to log to a file, you can just override this method
  #
  # Example of override:
  #   module Ramaze::Logger
  #     def puts(*args)
  #       File.open('log/default.log', 'a+') do |file|
  #         file.puts(*args)
  #       end
  #     end
  #   end
  # To use the Logger, you can just include it into your current namespace
  # or call it directly via (for example) Logger.debug('foo')
  #
  # Please note that, if you pass multiple parameters, they are being joined to
  # a single String (seperator is ' ').
  # Also, if an argument is not a String, it will be called inspect upon and the
  # result is used instead.

  module Logger

    # if the Global.mode is :debug this will output debugging-information
    # and prefix it with 'd'
    # Examples:
    #   Logger.debug :this_method, params        # =>
    #   Logger.debug :this_method, return_values # =>
    #   Logger.debug 'foo', 'bar', 32            # =>
    #   23.10.2006 09:29:33 D | foo, bar, 32

    def debug *args
      if logger_mode? :debug, :benchmark
        prefix = Global.logger[:prefix_debug] rescue 'DEBUG'
        log prefix, args
      end
    end

    # A very simple but powerful error-logger.
    # You can pass it both usual stuff and error-objects, which have
    # to respond to :message and :backtrace
    #
    # Example:
    #   def foo
    #     raise ExampleError, "aaah, something's gone wrong"
    #   rescue ExampleError => ex
    #     Logger.error ex
    #   end

    def error e
      if logger_mode? :live, :stage, :debug, :benchmark
        prefix = Global.logger[:prefix_error] rescue 'ERROR'
        if e.respond_to?(:message) and e.respond_to?(:backtrace)
          log prefix, e.message
          if logger_mode? :stage, :debug, :benchmark
            log prefix, *e.backtrace[0..15]
          end
        else
          log prefix, e
        end
      end
    end

    # The usual info-logger
    # Example:
    #   Logger.info

    def info *args
      if logger_mode? :stage, :debug, :benchmark
        prefix = Global.logger[:prefix_info] rescue 'INFO '
        log prefix, args
      end
    end

    private

    def timestamp
      mask = Global.logger[:timestamp] rescue "%Y-%m-%d %H:%M:%S"
      Time.now.strftime(mask)
    end

    def logger_mode? *modes
      modes.include?(Global.mode)
    end

    def log prefix, *args
      args.each do |arg|
        print "[#{timestamp}] #{prefix}  "
        puts [arg].flatten.map{|e| e.is_a?(String) ? e : e.inspect}.join(', ')
      end
    end

    def puts *args
      Kernel.puts(*args)
    end

    extend self
  end

  include Logger
end
