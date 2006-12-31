class OpenStruct
  def temp hash
    self.new(@table.merge(hash))
  end
end
