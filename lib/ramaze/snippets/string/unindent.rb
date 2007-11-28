class String
  def unindent
    space = self.split("\n")[1].to_s[/^(\s+)/, 1]
    strip.gsub(/^#{space}/, '')
  end
  alias ui unindent
end
