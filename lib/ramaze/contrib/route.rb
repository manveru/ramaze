#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Contrib
    class Route
      class << self
        def startup
          warn "Ramaze::Contrib::Route is being deprecated, use Ramaze::Route instead"
        end

        def [](key)
          Ramaze::Route.trait[:routes][key]
        end

        def []=(key, value)
          Ramaze::Route.trait[:routes][key] = value
        end
      end
    end
  end
end
