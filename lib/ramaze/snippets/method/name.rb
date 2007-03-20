#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

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
    # parses things like <Method: A.d>
    inspect.gsub(/#<Method: .*?[\.#](.*?)>/, '\1')
  end
end
