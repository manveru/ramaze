module Ramaze
  def self.deprecated(from, to = nil)
    message = "%s is deprecated"
    message << ", use %s instead" unless to.nil?
    Log.warn(message % [from, to])
  end
end
