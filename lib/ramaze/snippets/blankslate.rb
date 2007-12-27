unless defined?(BlankSlate)
  if defined?(BasicObject)
    BlankSlate = BasicObject
  else
    class BlankSlate
      instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    end
  end
end
