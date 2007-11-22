class String
  def unindent
    strip.gsub(/^#{ self.split("\n")[1][/^(\s+)/,1] }/, '')
  end
  alias ui unindent
end