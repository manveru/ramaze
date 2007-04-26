#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'xosd'

module Ramaze

  class Xosd

    trait :timeout => 3
    trait :lines => 3

    trait :colors => {
      :error => "#FF0000",
      :info => "#00FF00",
      :warn => "#EAA61E",
      :debug => "#FFFFFF"
    }

    Informer.trait[:tags].each do |meth,foo|
      define_method(meth) do |*args|
        log(meth, args.join("\n"))
      end

      define_method("#{meth}?") do |*args|
        inform_tag?(meth)
      end
    end

    def log(type, *args)
      @osd.color = ancestral_trait[:colors][type.to_sym]

      args.each_with_index do |arg, i|
        @osd.display(arg, i)
      end
    end

    def init_osd
      @osd = ::Xosd.new(ancestral_trait[:lines])
      @osd.valign = 'top'
      @osd.vertical_offset = 20
      @osd.align = 'center'
      @osd.color = '#FFFFFF'
      @osd.outline_color = '#000000'
      @osd.outline_width = 1
      @osd.font = "-*-*-*-*-*-*-24-*-*-*-*-*-*-*"
      @osd.timeout = ancestral_trait[:timeout]
    end

    def self.startup
      instance = self.new
      instance.init_osd
      instance
    end
  end
end

=begin

  class Xosd < ::Xosd

    trait :lines => 3
    trait :timeout => 1

    trait :colors => {
      :error => "#FF0000",
      :info => "#00FF00",
      :warn => "#EAA61E",
      :debug => "#FFFFFF"
    }

    Informer.trait[:tags].each do |meth,foo|
      define_method(meth) do |*args|
        log(meth, args.join("\n"))
      end

      define_method("#{meth}?") do |*args|
        inform_tag?(meth)
      end
    end

    # Webrick

    def <<(*args)
      log('debug', args.join("\n"))
    end

    def log(type, message)
      self.color = trait[:colors][type]

      message.split("\n")[0..5].each_with_index do |m, i|
        display(m, i)
      end

    end

    class << self
      def startup
        @instance ||= new(trait[:lines])

        @instance.valign = "top"
      	@instance.vertical_offset = 20
      	@instance.align = "center"
      	@instance.shadow_offset = 5
      	@instance.font = "-*-*-*-*-*-*-20-*-*-*-*-*-*-*"
      	@instance.timeout = trait[:timeout]
      end
    end


  private

    def inform_tag?(inform_tag)
      Ramaze::Global.inform_tags.include?(inform_tag)
    end
  end

end
=end
