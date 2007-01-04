#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Ramaze
  module FormHelper
    ClassMap = {
      String  => :text,
      Time    => :time,
      Fixnum  => :number,
    }

    def form obj, options = {}
      default = {:except => /oid/, :submit => true}
      options = default.merge(options)

      if obj.respond_to? :serializable_attributes
        instance = obj.new
      else
        instance = obj
        obj = obj.class
      end

      attributes = obj.serializable_attributes
      out = []

      attributes.each do |attribute|
        keep = decide_attribute(attribute, options)
        next unless keep

        o = OpenStruct.new :klass => obj.ann[attribute].class,
                           :value => (instance.send(attribute) rescue nil),
                           :name  => attribute,
                           :title => (options.has_key?(attribute) ? options[attribute] : attribute)

        control = obj.ann[attribute].control
        control = ClassMap[o.klass] unless control.is_a?(Symbol)

        out << Control.send(control, o) unless control == :none
      end
      if options[:submit] == true
        out << %{<input type="submit" />}
      elsif options[:submit]
        out << %{<input type="submit" value="#{options[:submit]}" />}
      end
      out.join("<br />\n")
    end

    def decide_attribute(attribute, options)
      keep = true
      options.each do |key, values|
        return keep unless keep
        values = [values].flatten
        case key
        when :except, :reject, :exclude
          values.each do |value|
            if value.kind_of?(Regexp)
              keep = !attribute.to_s.match(value)
            else
              keep = attribute != value
            end
          end
        end
      end
      !!keep
    end

    module Control
      class << self

        def number o
          o.value ||= 0
          text(o)
        end

        def text o
          o.value ||= ""
          tag = ''
          tag << "#{o.title}: " if o.title
          tag << %{<input type="text" name="#{o.name}" value="#{o.value}" />}
        end

        def textarea o
          o.value ||= ""
          %{<textarea name="#{o.name}">#{o.value}</textarea>}
        end

        def date o
          o.value ||= Date.today
          selects = []
          selects << date_day(o.temp(:value => o.value.day))
          selects << date_month(o.temp(:value => o.value.month))
          selects << date_year(o.temp(:value => o.value.year))
          selects.join("\n")
        end

        def time o
          o.value ||= Time.now
          selects = []
          selects << date_day(    o.temp(:value => o.value.day))
          selects << date_month(  o.temp(:value => o.value.month))
          selects << date_year(   o.temp(:value => o.value.year))
          selects << time_hour(   o.temp(:value => o.value.hour))
          selects << time_minute( o.temp(:value => o.value.min))
          selects << time_second( o.temp(:value => o.value.sec))
          selects.join("\n")
        end

        def time_second(o) select(o.name, (0...60),     o.value) end
        def time_minute(o) select(o.name, (0...60),     o.value) end
        def time_hour(o)   select(o.name, (0...24),     o.value) end
        def date_day(o)    select(o.name, (1..31),      o.value) end
        def date_month(o)  select(o.name, (1..21),      o.value) end
        def date_year(o)   select(o.name, (1950..2050), o.value) end

        def select name, range, default
          out = %{<select name="#{name}">\n}
          range.each do |i|
            out << %{<option value="#{i}"#{' selected="selected"' if default == i}>#{i}</option>\n}
          end
          out << "</select>\n"
        end
      end
    end
  end
end
