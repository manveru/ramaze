# Modification for upcoming functionality in 1.9

class Method

  # name of the Method (example shows combination with the new Kernel#method)
  #
  #   class Foo
  #     def bar
  #       method.name
  #     end
  #   end
  #
  #   Foo.new.bar #=> 'bar'

  def name
    #<Method: A.d>
    inspect.gsub(/#<Method: .*?[\.#](.*?)>/, '\1')
  end
end
