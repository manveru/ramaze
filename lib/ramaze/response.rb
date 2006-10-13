module Ramaze
  class Response < OpenStruct
    class << self
      def create options = {}
        klass = self.new
        klass.instance_eval do
          @table = options.merge(@table)
        end
        klass
      end
    end

    def clear
      @table = {
        :out => '', 
        :head => {'Content-Type' => 'text/html'}
      }
      self
    end

    def inspect
    "<Response #{__id__}>"
    end
  end
end
