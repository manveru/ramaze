module Sequel
  class Model
    class << self
      def fill hash = Ramaze::Request.current.params
        create(hash)
      end
    end
  end
end
