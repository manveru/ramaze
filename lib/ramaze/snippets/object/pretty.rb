class Object
  def pretty s = ''
    PP.pp(self, s)
    s
  end
end
