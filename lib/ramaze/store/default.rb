require 'yaml/store'

module Ramaze
  module Store
    class Default
      attr_accessor :db

      def initialize filename = 'db.yaml'
        FileUtils.touch(filename)
        @db = YAML::Store.new(filename)
      end

      def method_missing(meth, *args, &block)
        @db.transaction do
          @db.send(meth, *args, &block)
        end
      end
      
      def [](key)
        @db.transaction do
          @db[key]
        end
      end

      def []=(key, value)
        @db.transaction do
          @db[key] = value
        end
      end
    end
  end
end
