#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'yaml/store'

module Ramaze
  module Store

    # A simple wrapper around YAML::Store

    class Default
      attr_accessor :db

      # create a new store with a filename

      def initialize filename = 'db.yaml'
        FileUtils.touch(filename)
        @db = YAML::Store.new(filename)
      end

      # pass on all methods inside a transaction

      def method_missing(meth, *args, &block)
        @db.transaction do
          @db.send(meth, *args, &block)
        end
      end

      # the actual content of the store in YAML format

      def to_yaml
        Db.dump(:x)
      end

      # loads the #to_yaml

      def original
        YAML.load(to_yaml)
      end

      # available keys of the store

      def keys
        original.keys
      end
    end
  end
end
