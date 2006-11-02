class Annotations
  @hash = Hash.new{|h,k| h[k] = {}}

  def self.method_missing(meth, *args, &block)
    @hash.send(meth, *args, &block)
  end
end

class Object
  def ann hash = nil
    if hash
      Annotations[self].merge! hash
    else
      Annotations[self]
    end
  end
end
