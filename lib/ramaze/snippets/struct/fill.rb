#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

class Struct

  # Action = Struct.new('Action', :template, :method, :params)
  #
  # a = Action.fill(:template => nil, :method => :meth, :params => [1])
  # # => #<struct Struct::Action template=nil, method=:meth, params=[1]>

  def self.fill(hash = {})
    instance = new
    hash.each do |key, value|
      next unless members.include?(key.to_s)
      instance.send("#{key}=", value)
    end
    instance
  end
end
