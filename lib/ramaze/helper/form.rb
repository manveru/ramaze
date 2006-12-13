module Ramaze
  module FormHelper
    def form obj
      attributes = obj.serializable_attributes
      instance = obj.new
      out = []
      attributes.each do |attribute|
        klass = obj.ann[attribute].class
        value = instance.send(attribute) rescue nil
        p obj.ann
        p klass => value
        p control = Control.trait[:class_map][klass.to_s.sym]

        out << 
        case klass.to_s.to_sym
        when 'String' : control_string( attribute, value || '' )
        when 'Fixnum' : control_number( attribute, value || 1 )
        when 'Time'   : control_time( attribute, value || Time.now )
        when 'Date'   : control_date( attribute, value || Date.today )
        else
          p klass
          control_string(attribute, (value || '').to_yaml)
        end
      end
      out.join("<br />\n") << %{<input type="submit">}
    end

    module Control
      class Fixnum
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end

      class Float
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end

      class File
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end

      class Array
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end

      class Checkbox
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end

      class Text
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end

      class Password
        def self.render name, value
          %{<input type="password" name="#{name}" value="#{value}" />}
        end
      end

      class Textarea
        def self.render name, value
          %{<textarea name="#{name}">#{value}</textarea>}
        end
      end

      class Options 
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end

      class RefersTo 
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end

      class HasMany
        def self.render name, value
          %{<input type="text" name="#{name}" value="#{value}" />}
        end
      end
    end

    module Control
      trait :class_map => {
        :String    => :text,
        :Fixnum    => :fixnum,
        :Time      => :time,
        :Date      => :date,
        :DateTime  => :datetime,
      }

      trait :control_map => {
        :fixnum       => :Fixnum,
        :integer      => :Fixnum,
        :float        => :Float,
        :file         => :File,
        :webfile      => :File,
        :array        => :Array,
        :date         => :Date,
        :true_class   => Checkbox,
        :boolean      => Checkbox,
        :checkbox     => Checkbox,
        :string       => Text,
        :password     => Password,
        :textarea     => Textarea,
        :options      => Options,
        :refers_to    => RefersTo,
        :has_one      => RefersTo,
        :belongs_to   => RefersTo,
        :has_many     => HasMany,
        :many_to_many => HasMany,
        :joins_many   => HasMany,
      }
    end

    def control_string name, value
      %{<input type="text" name="#{name}" value="#{value}" />}
    end

    def control_textarea name, value
      %{<textarea name="#{name}">#{value}</textarea>}
    end

    def control_number name, value
      %{<input type="text" name="#{name}" value="#{value}" />}
    end

    def control_date name, value
      %{
      <select>
        <option></option>
      </select>
      }
    end

    def control_time name, value
      selects = []
      selects << control_date_day(name, value.day)
      selects << control_date_month(name, value.month)
      selects << control_date_year(name, value.year)
      selects << control_time_hour(name, value.hour)
      selects << control_time_minute(name, value.min)
      selects << control_time_second(name, value.sec)
      selects.join("<br />\n")
    end

    def control_date_day name, value
      control_select name, (1..31), value
    end

    def control_date_month name, value
      control_select name, (1..21), value
    end

    def control_date_year name, value
      control_select name, (1950..2050), value
    end

    def control_time_hour name, value
      control_select name, (0...24), value
    end

    def control_time_minute name, value
      control_select name, (0...60), value
    end

    def control_time_second name, value
      control_select name, (0...60), value
    end

    def control_select name, range, default
      out = %{<select name="#{name}">\n}
      range.each do |i|
        out << %{<option value="#{i}"#{' default="default"' if default == i}>#{i}</option>\n}
      end
      out << "</select>\n"
    end
  end
end
