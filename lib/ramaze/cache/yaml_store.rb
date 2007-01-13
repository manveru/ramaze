#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
require 'yaml/store'

module Ramaze
  class YAMLStoreCache
    def initialize(file = 'cache.yaml')
      @cache = YAML::Store.new(file)
    end

    def [](key)
      transaction do |y|
        y[key]
      end
    end

    def []=(key, value)
      transaction do |y|
        y[key] = value
      end
    end

    def delete(*keys)
      transaction do |y|
        keys.each do |k|
          y.delete(k)
        end
      end
    end

    def values_at(*keys)
      transaction do |y|
        keys.map{|k| y[k]}
      end
    end

    def transaction(&block)
      @cache.transaction(&block)
    end
  end
end
