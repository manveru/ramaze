#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  # Equivalent to Route, why the heck do we have that?
  Rewrite = Innate::Route

  # Shortcut for defining new routes.
  def self.Route(name, value = nil, &block)
    Route[name] = value || block
  end

  def self.Rewrite(name, value = nil, &block)
    Rewrite[name] = value || block
  end
end
