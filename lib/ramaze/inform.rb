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
    trait :tags => {
      :debug  => lambda{|*m| m.map{|o| o.inspect} },
      :info   => lambda{|*m| m.map{|o| o.to_s}    },
      :warn   => lambda{|*m| m.map{|o| o.to_s}    },
      :error  => lambda do |m|
        break(m) unless m.respond_to?(:exception)
        bt = m.backtrace[0..Global.inform_backtrace_size]
        [ m.inspect ] + bt
      end
    }

    def rebuild_tags
      trait[:tags].each do |tag, block|
        define_method(tag) do |*messages|
          return unless inform_tag?(tag)
          log(tag, block[*messages])
        end

        define_method("#{tag}?") do
          inform_tag?(tag)
        end

        private tag
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

    def log tag, *messages
      messages.flatten!

      pipify(Global.inform_to).each do |do_color, pipe|
        next if pipe.respond_to?(:closed?) and pipe.closed?

        prefix = colorize(tag, Global["inform_prefix_#{tag}"], do_color)

        messages.each do |message|
          pipe.puts(log_interpolate(prefix, message))
        end
      end
    end

    def colorize tag, prefix, do_color
      return prefix unless Global.inform_color and do_color
      color = Global.inform_colors[tag] ||= :white
      prefix.send(color)
    end

    def log_interpolate prefix, text, timestamp = timestamp
      message = Global.inform_format.dup

      { '%time' => timestamp, '%prefix' => prefix, '%text' => text
      }.each{|from, to| message.gsub!(from, to) }

      message
    end

    def pipify *ios
      color, no_color = true, false

      ios.flatten.map do |io|
        case io
        when STDOUT, :stdout, 'stdout'
          [ color, STDOUT ]
        when STDERR, :stderr, 'stderr'
          [ color, STDERR ]
        when IO
          [ no_color, io  ]
        else
          [no_color, File.open(io.to_s, 'ab+')]
        end
      end
    end

    extend self

    rebuild_tags
  end

  # This class acts as a object you can pass to any other logger, it's basically
  # just including Inform and making its methods public

  class GlobalInformer
    include Inform

    public :error, :error?, :info, :info?, :debug, :debug?

    # this simply sends the parameters to #debug

    def <<(*str)
      debug(*str)
    end
  end

  # The usual instance of GlobalInformer, for example used for WEBrick

  Informer = GlobalInformer.new unless defined?(Informer)

  include Inform
end
