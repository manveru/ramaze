#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

Traits = Hash.new{|h,k| h[k] = {}}

class Object
  def trait hash = nil
    if hash
      Traits[self].merge! hash
    else
      Traits[self]
    end
  end

  def ancestors_trait key
    trait[key] ||
    (ancestors rescue self.class.ancestors).find{|a| a.trait[key]}.trait[key]
  end
end
