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

    private

    def form_attributes
      options.inject([]){|s,(k,v)| s << "#{k}='#{v}'" }.join(' ')
    end
  end

  class ClassForm < Form
    # User.schema.instance_variable_get('@columns')
    # [{:type=>:varchar, :name=>:name, :size=>255}, {:type=>:text, :name=>:description}]
    def generate
      columns = object.schema.instance_variable_get('@columns')
      columns.map{|hash| field_for(hash) }.join("\n")
    end

    def field_for(hash)
      case hash[:type]
      when :varchar
        field_input(hash[:name])
      when :text
        field_textarea(hash[:name])
      end
    end

    def field_input(name)
      "<input type='text' name='#{name}' />"
    end

    def field_textarea(name)
      "<textarea name='#{name}'></textarea>"
    end
  end

  class InstanceForm < Form
    def generate
      columns = object.class.schema.instance_variable_get('@columns')
      columns.map{|hash| field_for(hash) }.join("\n")
    end

    def field_for(hash)
      name = hash[:name]
      value = @object.send(name)

      case hash[:type]
      when :varchar
        field_input(name, value)
      when :text
        field_textarea(name, value)
      end
    end

    def field_input(name, value)
      "<input type='text' name='#{name}' value='#{value}'/>"
    end

    def field_textarea(name, value)
      "<textarea name='#{name}'>#{value}</textarea>"
    end
  end
end
