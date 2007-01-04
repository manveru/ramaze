#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
class Object
  def instance?
    not respond_to?(:new)
  end

  def self.instance?
    not respond_to?(:new)
  end
end
