class String
  def snake_case
    gsub(/\B[A-Z]/, '_\&').downcase.gsub(' ', '_')
  end
end
