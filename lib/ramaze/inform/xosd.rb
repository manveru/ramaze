#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'xosd'
require 'thread'

module Ramaze

  # Informer for the XOSD notification system for X11.
  #
  # You can install the ruby-bindings with:
  #   gem install xosd.

  class Xosd < ::Xosd
    attr_accessor :options

    include Informing

    DEFAULT = {
      :font_size       => 20,
      :font            => "-*-*-*-*-*-*-%d-*-*-*-*-*-*-*",
      :align           => 'center',
      :color           => '#FFFFFF',
      :lines           => 3,
      :valign          => 'top',
      :timeout         => 3,
      :outline_color   => "#000000",
      :outline_width   => 1,
      :vertical_offset => 20,
      :colors => {
        :error => "#FF0000",
        :info => "#00FF00",
        :warn => "#EAA61E",
        :debug => "#FFFF00"
      },
    }

    # keys to ignore when setting the options to the instance.
    IGNORE = [:colors, :font_size, :lines]

    # Here new messages are pushed to eventually displaying them.
    QUEUE = Queue.new

    # Create a new instance, valid options are in DEFAULT

    def initialize(options = {})
      @options = DEFAULT.merge(options)

      super(@options[:lines])

      @options.each do |key, value|
        next if IGNORE.include?(key)
        value %= @options[:font_size] if key == :font
        send("#{key}=", value)
      end

      Thread.new(self) do |xosd|
        loop do
          items = []
          lines = xosd.options[:lines]
          items << QUEUE.shift until QUEUE.empty? or items.size >= lines

          unless items.empty?
            # pad up with empty lines to avoid dragging around old messages.
            items << [:info, ' '] until items.size >= lines

            items.each_with_index do |(tag, message), i|
              xosd.color = xosd.options[:colors][tag.to_sym]
              xosd.display(message, i)
            end
          end
          sleep xosd.options[:timeout]
        end
      end
    end

    def inform(tag, *messages)
      messages.each do |message|
        QUEUE << [tag, message]
      end
    end
  end
end
