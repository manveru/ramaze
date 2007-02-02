#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # The module Inform is mainly used for Debugging and Logging.
  #
  # You can include/extend your objects with it and access its methods.
  # Please note that all methods are private, so you should use them only
  # within your object. The reasoning for making them private is simply
  # to avoid interference inside the controller.
  #
  # In case you want to use it from the outside you can work over the
  # Informer object. This is used for example as the Logger for WEBrick.
  #
  # Inform is a tag-based system, Global.inform_tags holds the tags
  # that are used to filter the messages passed to Inform. The default
  # is to use all tags :debug, :info and :error.
  #
  # You can control what gets logged over this Set.

  module Inform
    # the possible tags
    trait :tags => [:debug, :info, :error]

    private

    # general debugging information, this yields quite verbose information
    # about how requests make their way through Ramaze.
    #
    # Use it for your own debugging purposes.
    # All messages you pass to it are going to be inspected.
    # it is aliased to #D for convenience.

    def debug *messages
      return unless inform_tag?(:debug)
      log(Global.inform_prefix_debug, *messages.map{|m| m.inspect})
    end

    alias D debug

    # A little but powerful method to debug calls to methods.
    #
    #   def foo(*args)
    #     meth_debug(:foo, args)
    #   end
    #
    #   foo :bar
    #
    # Will give you
    #
    #   [2007-01-26 22:17:24] DEBUG  foo([:bar])
    #
    # It will also run inspect on all parameters you pass to it (only the
    # method-name is processed with to_s)
    #
    # It is aliased to #mD

    def meth_debug meth, *params
      return unless inform_tag?(:debug)
      log(Global.inform_prefix_debug, "#{meth}(#{params.map{|pa| pa.inspect}.join(', ')})")
    end

    alias mD meth_debug

    # General information about startup, requests and other things.
    #
    # Use of this method is mainly for things that are not overly verbose
    # but give you a general overview about what's happening.

    def info message
      return unless inform_tag?(:info)
      log(Global.inform_prefix_info, message)
    end

    # Informing yourself about errors, you can pass it instances of Error
    # but also simple Strings.
    # (all that responds to :message/:backtrace or to_s)
    #
    # It will nicely truncate the backtrace to:
    #   Global.inform_backtrace_size
    # It will not differentiate its behaviour based on other tags, as
    # having a full backtrace is the most valuable thing to fixing the issue.
    #
    # However, you can set a different behaviour by adding/removing tags from:
    #   Global.inform_backtrace_for
    # By default it just points to Global.inform_tags

    def error *messages
      return unless inform_tag?(:error)
      prefix = Global.inform_prefix_error
      messages.each do |e|
        if e.respond_to?(:message) and e.respond_to?(:backtrace)
          log prefix, e.message
          if (Global.inform_backtrace_for || Global.inform_tags).any?{|t| inform_tag?(t)}
            e.backtrace[0..10].each do |bt|
              log prefix, bt
            end
          end
        else
          log prefix, e
        end
      end
    end

    # This uses Global.inform_timestamp or a date in the format of
    #   %Y-%m-%d %H:%M:%S
    #   # => "2007-01-19 21:09:32"

    def timestamp
      mask = Global.inform_timestamp
      Time.now.strftime(mask || "%Y-%m-%d %H:%M:%S")
    end

    # is the given inform_tag in Global.inform_tags ?

    def inform_tag?(inform_tag)
      Global.inform_tags.include?(inform_tag)
    end

    # the common logging-method, you shouldn't have to call this yourself
    # it takes the prefix and any number of messages.
    #
    # The produced inform-message consists of
    #   [timestamp] prefix  message
    # For the output is anything used that responds to :puts, the default
    # is $stdout in:
    #   Global.inform_to
    # where you can configure it.
    #
    # To log to a file just do
    #   Global.inform_to = File.open('log.txt', 'a+')

    def log prefix, *messages
      [messages].flatten.each do |message|
        compiled = %{[#{timestamp}] #{prefix}  #{message}}
        out =
          case Global.inform_to
          when $stdout, :stderr, 'stdout' : $stdout
          when $stdout, :stderr, 'stderr' : $stderr
          else
            File.open(Global.inform_to, 'r+')
          end
        out.puts(*compiled) unless (out.respond_to?(:closed?) and out.closed?)
      end
    end

    extend self
  end

  class GlobalInformer
    include Inform

    public :error, :info, :meth_debug, :debug

    # this simply sends the parameters to #debug

    def <<(*str)
      debug(*str)
    end
  end

  Informer = GlobalInformer.new

  include Inform
end
