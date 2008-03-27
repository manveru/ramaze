module Ramaze
  module Helper
    module Form
      def form_for(object, options = {})
        Ramaze::Form.pick(object, options)
      end
    end
  end

  class Form
    attr_accessor :object, :options

    YEARS, MONTHS, DAYS, HOURS, MINUTES, SECONDS =
      (1900..2100), (1..12), (1..31), (0..23), (0..59), (0..59)

    # How _elegant_ ...
    def self.pick(object, options = {})
      if defined?(Sequel::Model)
        if object.is_a?(Sequel::Model)
          options[:layer] ||= Layer::Sequel
          InstanceForm.new(object, options)
        elsif object.ancestors.include?(Sequel::Model)
          options[:layer] ||= Layer::Sequel
          ClassForm.new(object, options)
        end
      else
        raise "Unknown ORM for: %p" % object
      end
    end

    def initialize(object, options = {})
      @object, @options = object, options
      if layer = options.delete(:layer)
        extend layer
      end
    end

    def to_s
      out = "<form #{form_attributes}>"
      out << "<fieldset>"
      out << generate
      out << "</fieldset>"
      out << "</form>"
    end

    def field_for(hash)
      return if hash[:primary_key]
      args = args_for(hash)

      inner =
        case type = hash[:type]
        when :integer
          field_integer(*args)
        when :boolean
          field_boolean(*args)
        when :text
          field_textarea(*args)
        when :varchar
          field_input(*args)
        when :date
          field_date(*args)
        when :time
          field_time(*args)
        else
          Log.warn "Unknown field: %p" % hash
          field_input(*args)
        end

      "<label>#{args.first}: </label>\n#{inner}"
    end

    private

    def form_attributes
      options.inject([]){|s,(k,v)| s << "#{k}='#{v}'" }.join(' ')
    end

    def start_tag(name, hash)
      hash.inject("<#{name}"){|s,(k,v)| s << " #{k}='#{v}'" }
    end

    def closed_tag(name, hash)
      start_tag(name, hash) << ' />'
    end

    def textarea(value, hash = {})
      start_tag(:textarea, hash) << ">#{value}</textarea>"
    end

    def input(hash = {})
      closed_tag(:input, hash)
    end

    def checkbox(hash = {})
      hash[:type] = :checkbox
      input(hash)
    end

    def option(value, hash = {})
      start_tag(:option, hash) << ">#{value}</option>"
    end

    def field_date_generic
      [ [ :day, DAYS ],
        [ :month, MONTHS ],
        [ :year, YEARS ],
      ].map{|(sel, range)|
        yield(sel, range).join
      }.join("\n")
    end

    def field_time_generic
      [ [ :day, DAYS ],
        [ :month, MONTHS ],
        [ :year, YEARS ],
        [ :hour, HOURS ],
        [ :min, MINUTES ],
        [ :sec, SECONDS ]
      ].map{|(sel, range)|
        yield(sel, range).join
      }.join("\n")
    end

    module Layer
      module Sequel
        def generate
          columns = object_class.schema.instance_variable_get('@columns')
          columns.map{|hash| field_for(hash) }.flatten.join("<br />\n")
        end
      end
    end
  end

  class ClassForm < Form
    def field_input(name)
      input :name => name
    end

    def field_textarea(name)
      textarea '', :name => name
    end

    def field_integer(name)
      input :name => name
    end

    def field_boolean(name)
      checkbox :name => name
    end

    def field_date(name)
      field_date_generic{|sel, range|
        [ "<select name='#{name}[#{sel}]'>",
          range.map{|d| option(d, :value => d) },
          "</select>" ]
      }
    end

    def field_time(name)
      field_time_generic{|sel, range|
        [ "<select name='#{name}[#{sel}]'>",
          range.map{|d| option(d, :value => d) },
          "</select>" ]
      }
    end

    def args_for(hash)
      [ hash[:name] ]
    end

    def object_class
      @object
    end
  end

  class InstanceForm < Form
    def field_input(name, value)
      "<input type='text' name='#{name}' value='#{value}'/>"
    end

    def field_textarea(name, value)
      "<textarea name='#{name}'>#{value}</textarea>"
    end

    def field_integer(name, value)
      field_input(name, value)
    end

    def field_boolean(name, value)
      if value
        checkbox :name => name, :value => value, :checked => :checked
      else
        checkbox :name => name, :value => value
      end
    end

    def field_date(name, value)
      field_date_generic do |sel, range|
        [ "<select name='#{name}[#{sel}]'>",
          option_range_selected(range, value.send(sel)),
          "</select>" ]
      end
    end

    def field_time(name, value)
      field_time_generic do |sel, range|
        [ "<select name='#{name}[#{sel}]'>",
          option_range_selected(range, value.send(sel)),
          "</select>" ]
      end
    end

    def option_range_selected(range, value)
      range.map do |r|
        if r == value
          option(r, :value => r, :selected => :selected)
        else
          option(r, :value => r)
        end
      end
    end

    def args_for(hash)
      name = hash[:name]
      [ name, @object.send(name) ]
    end

    def object_class
      @object.class
    end
  end
end
