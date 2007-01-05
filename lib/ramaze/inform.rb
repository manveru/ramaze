#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # The central interface-tool for Ramaze, it just spits out all the things
  # you always wanted to tell your user but didn't dare to ;)
  #
  # Important to the Inform is especially Global.mode, which can be
  # one of:
  #  Global.mode = :benchmark # switch all logging on and bench requests
  #  Global.mode = :debug     # switch all logging on
  #  Global.mode = :stage     # switch on info- and errorlogging
  #  Global.mode = :live      # switch on errorlogging
  #  Global.mode = :silent    # switch off logging
  #
  #
  # It has a method called Inform#puts which uses per default Kernel#puts
  # and which is called by the central #log method (that in turn is used by
  # all the other logging-methods)
  #
  # Example of use:
  #   Inform.info "Hello, World!"
  #   include Inform
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
  #   module Ramaze::Inform
  #     def puts(*args)
  #       File.open('log/default.log', 'a+') do |file|
  #         file.puts(*args)
  #       end
  #     end
  #   end
  # To use the Inform, you can just include it into your current namespace
  # or call it directly via (for example) Inform.debug('foo')
  #
  # Please note that, if you pass multiple parameters, they are being joined to
  # a single String (seperator is ' ').
  # Also, if an argument is not a String, it will be called inspect upon and the
  # result is used instead.

  module Inform

    # if the Global.mode is :debug this will output debugging-information
    # and prefix it with 'd'
    # Examples:
    #   Inform.debug :this_method, params        # =>
    #   Inform.debug :this_method, return_values # =>
    #   Inform.debug 'foo', 'bar', 32            # =>
    #   23.10.2006 09:29:33 D | foo, bar, 32

    def debug *args
      if inform_mode? :debug, :benchmark
        prefix = Global.inform[:prefix_debug] rescue 'DEBUG'
        log prefix, *args
      end
    end

    # A very simple but powerful error-inform.
    # You can pass it both usual stuff and error-objects, which have
    # to respond to :message and :backtrace
    #
    # Example:
    #   def foo
    #     raise ExampleError, "aaah, something's gone wrong"
    #   rescue ExampleError => ex
    #     Inform.error ex
    #   end

    def error *errors
      if inform_mode? :live, :stage, :debug, :benchmark
        prefix = Global.inform[:prefix_error] rescue 'ERROR'
        errors.each do |e|
          if e.respond_to?(:message) and e.respond_to?(:backtrace)
            log prefix, e.message
            if inform_mode? :stage, :debug, :benchmark
              log prefix, *e.backtrace[0..15]
            end
          else
            log prefix, e
          end
        end
      end
    end

    # The usual info-inform
    # Example:
    #   Inform.info

    def info *args
      if inform_mode? :stage, :debug, :benchmark
        prefix = Global.inform[:prefix_info] rescue 'INFO '
        log prefix, *args
      end
    end

    def puts *args
      debug(*args)
    end

    def <<(*args)
      puts(*args)
    end

    private

    def timestamp
      mask = Global.inform[:timestamp]
      Time.now.strftime(mask)
    rescue
      Time.now.strftime("%Y-%m-%d %H:%M:%S")
    end

    def inform_mode? *modes
      modes.include?(Global.mode)
    end

    def log prefix = '', *args
      args.each do |arg|
        print "[#{timestamp}] #{prefix}  "
        Kernel.puts [arg].flatten.map{|e| e.is_a?(String) ? e : e.inspect}.join(', ')
      end
    end

    extend self
  end

  include Inform
end
