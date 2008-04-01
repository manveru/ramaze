class String
  # Useful for writing indented String and unindent on demand, based on the
  # first line with indentation.
  def unindent
    space = self.split("\n").find{|l| !l.strip.empty?}.to_s[/^(\s+)/, 1]
    strip.gsub(/^#{space}/, '')
  end
  alias ui unindent

  # Destructive variant of undindent, replacing the String
  def unindent!
    self.replace unindent
  end
  alias ui! unindent!
end
