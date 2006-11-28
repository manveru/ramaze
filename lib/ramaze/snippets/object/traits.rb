Traits = Hash.new{|h,k| h[k] = {}}

class Object
  def trait hash = nil
    if hash
      Traits[self].merge! hash
    else
      Traits[self]
    end
  end
end
