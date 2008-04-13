module Ramaze
  module Helper
    module Provide
      def self.included(klass)
        def klass.provides(*formats)
          # Ramaze::Route[/(.*?)\.(\w+)$/] = "%s/"
          trait[:formats] = formats
        end
      end

      def display(object)
        p :display => object
        p request
        object
      end
    end
  end
end
