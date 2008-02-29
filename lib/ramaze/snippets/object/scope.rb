class Object

  # returns a new clean binding for this object
  #   usage: eval 'self', object.scope  #=> returns object 
  #

  def scope
    lambda{}
  end

end
