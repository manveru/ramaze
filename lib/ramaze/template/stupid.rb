module Ramaze::Template
  class Stupid < Default
    class << self
      def transform string
        eval(string)
      end
    end
  end
end
