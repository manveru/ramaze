#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

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
