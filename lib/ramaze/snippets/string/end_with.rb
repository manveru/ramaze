class String
  unless method_defined?(:end_with?)
    # Compatibility with 1.9
    def end_with?(other)
      other = other.to_s
      self[-other.size, other.size] == other
    end
  end
end
