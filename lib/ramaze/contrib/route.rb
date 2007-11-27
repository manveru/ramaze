#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

# Usage:
#
#   Ramaze.contrib :route
#   Ramaze::Contrib::Route[ %r!^/(\d+\.\d{2})$! ] = "/price/%.2f"

module Ramaze
  module Contrib
    class Route
      class << self
        def startup
          trait :route => true
          trait :routes => Dictionary.new
          Ramaze::Controller::FILTER.put_before(:default, :routed)
        end

        def [](key)
          trait[:routes][key]
        end

        def []=(key, value)
          trait[:routes][key] = value
        end
      end
    end
  end

  class Controller
    class << self
      def routed(path)
        routes = Contrib::Route.trait[:routes]
        routes.each do |regex, pattern|
          if md = path.match(regex)
            new_path = pattern % md.to_a[1..-1]
            return resolve(new_path, :routed)
          end
        end

        nil
      end
    end
  end
end
