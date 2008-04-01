class String
  unless method_defined?(:start_with?)
    # Compatibility with 1.9
    def start_with?(other)
      self[0, other.size] == other
    end
  end
end
