module Ramaze::Template
  class Stupid < Default
    ann :actionless => false

    class << self
      include Trinity

      def transform string
        eval(string)
      end
    end
  end
end
