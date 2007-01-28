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
    end
  end
end
