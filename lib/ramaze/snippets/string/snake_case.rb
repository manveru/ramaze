#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
class String

  # convert to snake_case from CamelCase
  #
  #   'FooBar'.snake_case # => 'foo_bar'

  def snake_case
    gsub(/\B[A-Z]/, '_\&').downcase.gsub(' ', '_')
  end
end
