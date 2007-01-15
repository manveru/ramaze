#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FormHelper
    ClassMap = {
      String  => :text,
      Time    => :time,
      Date    => :date,
      Fixnum  => :number,
    }

    def form obj, options = {}
      default = {:deny => /oid/, :submit => true}
      options = default.merge(options)

      if obj.respond_to? :serializable_attributes
        instance = obj.new
      else
        instance = obj
        obj = obj.class
      end

      attributes = obj.serializable_attributes
      out = []

      chosen_attributes(attributes, options).each do |attribute|

        o = OpenStruct.new :klass => obj.ann[attribute].class,
                           :value => (instance.send(attribute) rescue nil),
                           :name  => attribute.to_s,
                           :title => (options.has_key?(attribute) ? options[attribute] : attribute)

        control = obj.ann[attribute].control
        control = ClassMap[o.klass] unless control.is_a?(Symbol)

        out << Control.send(control, o) unless control.nil? or control == :none
      end
      if options[:submit] == true
        out << %{<input type="submit" />}
      elsif options[:submit]
        out << %{<input type="submit" value="#{options[:submit]}" />}
      end
      out.join("<br />\n")
    end

    # options #=>
    # { :deny => /oid/ }
    # { :deny => [/time/, /oid/]}

    def chosen_attributes(attributes, options)
      attributes.reject do |attribute|
        attribute = attribute.to_s
        [options[:deny]].flatten.find do |d|
          first_comp = attribute =~ d rescue attribute == d
          first_comp || attribute == d
        end
      end
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

        def time o
          o.value ||= Time.now
          [
            date_day(o.temp(:value => o.value.day)),
            date_month(o.temp(:value => o.value.month)),
            date_year(o.temp(:value => o.value.year)),
            time_hour(o.temp(:value => o.value.hour)),
            time_minute(o.temp(:value => o.value.min)),
            time_second(o.temp(:value => o.value.sec)),
          ].join("\n")
        end

        def time_second(o)
          select(o.name + '[sec]', (0...60), o.value)
        end

        def time_minute(o)
          select(o.name + '[min]', (0...60), o.value)
        end

        def time_hour(o)
          select(o.name + '[hour]', (0...24), o.value)
        end

        def date o
          o.value ||= Date.today
          [
            date_day(o.temp(:value => o.value.day)),
            date_month(o.temp(:value => o.value.month)),
            date_year(o.temp(:value => o.value.year)),
          ].join("\n")
        end

        def date_day(o)
          select(o.name + '[day]', (1..31), o.value)
        end

        def date_month(o)
          select(o.name + '[month]', (1..21), o.value)
        end

        def date_year(o)
          select(o.name + '[year]', (1950..2050), o.value)
        end

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
