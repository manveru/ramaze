class String
  def unindent
    space = self.split("\n").find{|l| !l.strip.empty?}.to_s[/^(\s+)/, 1]
    strip.gsub(/^#{space}/, '')
  end
  alias ui unindent

  def unindent!
    self.replace unindent
  end
  alias ui! unindent!
end
