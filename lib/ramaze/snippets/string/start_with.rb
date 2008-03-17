class String
  unless method_defined?(:start_with?)
    def start_with?(other)
      self[0, other.size] == other
    end
  end
end
