module Ramaze
  module MarukuHelper
    def maruku(text)
      Maruku.new(text).to_html
    end
  end
end
