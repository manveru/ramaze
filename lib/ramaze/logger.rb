module Ramaze

  # The central interface-tool for Ramaze, it just spits out all the things
  # you always wanted to tell your user but didn't dare to ;)
  #
  # Important to the Logger is especially Global.mode, which can be
  # one of:
  #  Global.mode = :debug  # switch on info-, debug-, errorlogging
  #  Global.mode = :stage  # switch on info- and errorlogging
  #  Global.mode = :live   # switch on errorlogging
  #  Global.mode = :silent # switch off logging
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
  #
  # TODO: 
  # - make the seperator configurable
  # - also add a timestamping-functionality

  module Logger

    # if the Global.mode is :debug this will output debugging-information
    # and prefix it with 'd'
    # Example:
    #   Logger.debug 'foo'
    #   # will print
    #   d-| foo

    def debug *args
      log('d', *args) if logger_mode? :debug
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
      if logger_mode? :live, :stage, :debug
        puts
        if e.respond_to?(:message) and e.respond_to?(:backtrace)
          log '!', e.message
          e.backtrace.each{|bt| log('!  ', bt) }
        else
          log '!', e
        end
      end
    end

    # The usual info-logger
    # Example:
    #   Logger.info

    def info *args
      if logger_mode? :stage, :debug
        log '-', *args
      end
    end

    private

    def logger_mode? *modes
      modes.include?(Global.mode)
    end

    def log *args
      puts "-|" + args.map{|a| a.is_a?(String) ? a : a.inspect}.join('-|')
    end

    def puts *args
      Kernel.puts(*args)
    end

    extend self
    include self
  end
end
