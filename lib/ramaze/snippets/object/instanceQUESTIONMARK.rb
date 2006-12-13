class Object
  def instance?
    not respond_to?(:new)
  end

  def self.instance?
    not respond_to?(:new)
  end
end
