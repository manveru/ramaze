class String

  {
    :red => 31,
    :green => 32,
    :yellow => 33,
  }.each do |key, value|
    define_method key do
      "\e[#{value}m" + self + "\e[0m"
    end
  end
end

