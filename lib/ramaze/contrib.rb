module Ramaze
  class << self
    def contrib(*contribs)
      contribs.each do |name|
        require "ramaze/contrib/#{name}"
        Ramaze.const_get(name.to_s.camel_case).startup
      end
    end
  end
end
