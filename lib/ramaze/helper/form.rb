#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module FormHelper

    # Mapping different classes to an specific method on FormHelper::Control.

    ClassMap = {
      String  => :text,
      Time    => :time,
      Date    => :date,
      Fixnum  => :number,
    }

    # Create the contents of a <form> for Og-objects.
    # This can be an instance or the class itself. Depending if you
    # want to edit an object or create a new one.
    #
    # Please note that the enclosing <form> itself is not (yet) generated.
    #
    # attributes that have no mapping in ClassMap are silently ignored.

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

    # Home of all the methods that output a tag for a specific
    # attribute.
    # They take objects that respond to :value and :name, preferably
    # an modified OpenStruct that responds to :temp to allow for easy
    # forking. ( lib/ramaze/snippets/openstruct/temp.rb )

    module Control
      class << self

        # A simple text-control, default to 0

        def number o
          o.value ||= 0
          text(o)
        end

        #   <input type="text" />

        def text o
          o.value ||= ""
          tag = ''
          tag << "#{o.title}: " if o.title
          tag << %{<input type="text" name="#{o.name}" value="#{o.value}" />}
        end

        #   <textarea></textarea>

        def textarea o
          o.value ||= ""
          %{<textarea name="#{o.name}">#{o.value}</textarea>}
        end

        # compound of #date_day, #date_month, #date_year, #time_hour,
        # #time_minute and #time_second

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

        #   <select name="xxx[sec]">
        #     <option value="0">0</option>
        #     ...
        #     <option value="60">60</option>
        #   </select>

        def time_second(o)
          select(o.name + '[sec]', (0...60), o.value)
        end

        #   <select name="xxx[min]">
        #     <option value="0">0</option>
        #     ...
        #     <option value="60">60</option>
        #   </select>

        def time_minute(o)
          select(o.name + '[min]', (0...60), o.value)
        end

        #   <select name="xxx[hour]">
        #     <option value="1">1</option>
        #     ...
        #     <option value="23">23</option>
        #   </select>

        def time_hour(o)
          select(o.name + '[hour]', (0...23), o.value)
        end

        # compound of #date_day, #date_month and #date_year

        def date o
          o.value ||= Date.today
          [
            date_day(o.temp(:value => o.value.day)),
            date_month(o.temp(:value => o.value.month)),
            date_year(o.temp(:value => o.value.year)),
          ].join("\n")
        end

        #   <select name="xxx[day]">
        #     <option value="1">1</option>
        #     ...
        #     <option value="31">31</option>
        #   </select>

        def date_day(o)
          select(o.name + '[day]', (1..31), o.value)
        end

        #   <select name="xxx[month]">
        #     <option value="1">1950</option>
        #     ...
        #     <option value="12">12</option>
        #   </select>

        def date_month(o)
          select(o.name + '[month]', (1..12), o.value)
        end

        #   <select name="xxx[year]">
        #     <option value="1950">1950</option>
        #     ...
        #     <option value="2050">2050</option>
        #   </select>

        def date_year(o)
          select(o.name + '[year]', (1950..2050), o.value)
        end

        #  <select>
        #    <option></option>
        #  </select>

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
