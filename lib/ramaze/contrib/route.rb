module Ramaze
  class Route
    class << self
      def startup
        trait :route => true
        trait :routes => Dictionary.new
      end

      def [](key)
        trait[:routes][key]
      end

      def []=(key, value)
        trait[:routes][key] = value
      end
    end
  end

  class Controller
    class << self
      def routed(path)
        routes = Route.trait[:routes]
        routes.each do |regex, pattern|
          if md = path.match(regex)
            return resolve(pattern % md.to_a[1..-1])
          end
        end

        nil
      end
    end
  end
end
