class Object
  # Available in 1.8.6 and later.
  unless method_defined?(:instance_variable_defined?)
    def instance_variable_defined?(variable)
      instance_variables.include?(variable.to_s)
    end
  end
end
