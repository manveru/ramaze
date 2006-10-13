module Ramaze::Template
  module Default
    def initialize request
      @request = request
      @out = request.out
    end

    def request
      @request.out = @out
      @request
    end
  end
end
