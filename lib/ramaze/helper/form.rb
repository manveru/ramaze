module Ramaze
  module Helper
    module Form
      def form_for(object, options = {})
        if object.respond_to?(:schema)
          Ramaze::ClassForm.new(object, options)
        else
          Ramaze::InstanceForm.new(object, options)
        end
      end
    end
  end

  class Form
    attr_accessor :object, :options

    def initialize(object, options = {})
      @object, @options = object, options
    end

    def to_s
      out = "<form #{form_attributes}>"
      out << generate
      out << "</form>"
    end

    def field_for(hash)
      return if hash[:primary_key]
      args = args_for(hash)

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
      else
        Log.warn "Unknown field: %p" % hash
        field_input(*args)
      end
    end

    private

    def generate
      columns = object_class.schema.instance_variable_get('@columns')
      columns.map{|hash| field_for(hash) }.flatten.join("\n")
    end


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
      [ :day, :month, :year #, :hour, :minute, :second
      ].map{|part|
        [ "<select name='#{name}[#{part}]'>",
          send("field_date_#{part}"),
          "</select>"
        ]
      }
    end

    def field_date_day
      (1..31).map{|d| option(d, :value => d) }
    end

    def field_date_month
      (1..12).map{|d| option(d, :value => d) }
    end

    def field_date_year
      (1900..2100).map{|d| option(d, :value => d) }
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
      [ :day, :month, :year #, :hour, :minute, :second
      ].map{|part|
        [ "<select name='#{name}[#{part}]'>",
          send("field_date_#{part}", value),
          "</select>"
        ]
      }
    end

    def field_date_day(value)
      option_range_selected(0..31, value.day)
    end

    def field_date_month(value)
      option_range_selected(1..12, value.month)
    end

    def field_date_year(value)
      option_range_selected(1900..2100, value.year)
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
