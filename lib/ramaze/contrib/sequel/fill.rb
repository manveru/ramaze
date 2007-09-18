module Sequel
  class Model
    class << self
      def fill request_object = Ramaze::Request.current
        create(request_object.params)
      end
    end
  end
end
