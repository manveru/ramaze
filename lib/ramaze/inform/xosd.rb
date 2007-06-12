#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'xosd'

module Ramaze

  class Xosd < ::Xosd
    include Informing

    trait :timeout => 3
    trait :lines => 3

    trait :colors => {
      :error => "#FF0000",
      :info => "#00FF00",
      :warn => "#EAA61E",
      :debug => "#FFFFFF"
    }

    def initialize font_size = 24
      super(class_trait[:lines])

      self.font            = "-*-*-*-*-*-*-#{font_size}-*-*-*-*-*-*-*"
      self.align           = 'center'
      self.color           = '#FFFFFF'
      self.valign          = 'top'
      self.timeout         = class_trait[:timeout]
      self.outline_color   = "#000000"
      self.outline_width   = 1
      self.vertical_offset = 20
    end

    def inform(tag, *args)
      self.color = class_trait[:colors][tag.to_sym]

      args.each_with_index do |arg, i|
        display(arg, i)
      end
    end
  end
end
