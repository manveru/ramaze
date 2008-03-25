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
      else
        Log.warn "Unknown field: %p" % hash
        field_input(*args)
      end
    end

    private

    def generate
      columns = object_class.schema.instance_variable_get('@columns')
      columns.map{|hash| field_for(hash) }.join("\n")
    end


    def form_attributes
      options.inject([]){|s,(k,v)| s << "#{k}='#{v}'" }.join(' ')
    end
  end

  class ClassForm < Form
    def field_input(name)
      "<input type='text' name='#{name}' />"
    end

    def field_textarea(name)
      "<textarea name='#{name}'></textarea>"
    end

    def field_integer(name)
      field_input(name)
    end

    def field_boolean(name)
      "<input type='checkbox' name='#{name}' />"
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
        "<input type='checkbox' name='#{name}' value='#{value}' checked='checked' />"
      else
        "<input type='checkbox' name='#{name}' value='#{value}' />"
      end
    end

    def field_date(name, value)
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
