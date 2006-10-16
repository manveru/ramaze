class String
  def / obj
    File.join(self, obj.to_s)
  end
end
