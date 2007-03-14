#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
require 'yaml/store'

module Ramaze
  class YAMLStoreCache

    # create a new YAML::Store with the given file (which will be created if it
    # is not already there).

    def initialize(file = 'cache.yaml')
      @cache = YAML::Store.new(file)
    end

    # return the values for given keys.

    def values_at(*keys)
      transaction do |y|
        keys.map{|k| y[k]}
      end
    end

    # just a helper to use transactions.

    def transaction(&block)
      @cache.transaction do
        yield(@cache)
      end
    end

    # catch everything else and use a transaction to send it.

    def method_missing(*args, &block)
      transaction do |y|
        y.send(*args, &block)
      end
    end
  end
end
