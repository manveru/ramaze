module Ramaze::Template
  class Stupid < Default
    trait :actionless => false

    class << self
      include Trinity

      def transform string
        eval(string)
      end
    end
  end
end
