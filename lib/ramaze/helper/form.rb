module Ramaze
  module FormHelper
    ClassMap = {
      String  => :text,
      Time    => :time,
      Fixnum  => :number,
    }

    def form obj
      if obj.respond_to? :serializable_attributes
        instance = obj.new
      else
        instance = obj
        obj = obj.class
      end

      attributes = obj.serializable_attributes
      out = []

      attributes.each do |attribute|
        klass   = obj.ann[attribute].class
        control = obj.ann[attribute].control
        value   = instance.send(attribute) rescue nil
        control = ClassMap[klass] unless control.is_a?(Symbol)

        p :klass => klass, :control => control, :value => value
        out << Control.send(control, attribute, value)
      end
      out.join("<br />\n")
    end

    module Control
      class << self

        def number name, value
          value ||= 0
          text(name, value)
        end

        def text name, value
          value ||= ""
          %{<input type="text" name="#{name}" value="#{value}" />}
        end

        def textarea name, value
          value ||= ""
          %{<textarea name="#{name}">#{value}</textarea>}
        end

        def date name, value
          value ||= Date.today
          selects = []
          selects << date_day(name, value.day)
          selects << date_month(name, value.month)
          selects << date_year(name, value.year)
          selects.join("\n")
        end

        def time name, value
          value ||= Time.now
          selects = []
          selects << date_day(name, value.day)
          selects << date_month(name, value.month)
          selects << date_year(name, value.year)
          selects << time_hour(name, value.hour)
          selects << time_minute(name, value.min)
          selects << time_second(name, value.sec)
          selects.join("\n")
        end

        def date_day name, value
          select name, (1..31), value
        end

        def date_month name, value
          select name, (1..21), value
        end

        def date_year name, value
          select name, (1950..2050), value
        end

        def time_hour name, value
          select name, (0...24), value
        end

        def time_minute name, value
          select name, (0...60), value
        end

        def time_second name, value
          select name, (0...60), value
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
