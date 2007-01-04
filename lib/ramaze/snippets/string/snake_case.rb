#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
class String
  def snake_case
    gsub(/\B[A-Z]/, '_\&').downcase.gsub(' ', '_')
  end
end
