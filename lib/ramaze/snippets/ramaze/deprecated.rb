module Ramaze
  def self.deprecated(from, to)
    message = "%s is deprecated, use %s instead" % [from, to]
    Log.warn(message)
  end
end
