require 'ramaze/gostruct'
module Ramaze
  class Global < GlobalOpenStruct
    class << self
      def values_at(*keys)
        keys.map{|k| self[k]}
      end

      def []=(key, value)
        self.send("#{key}=", value)
      end

      def [](key)
        self.send(key)
      end
    end

    def inspect
      "<Global #{__id__}>"
    end
  end
end
