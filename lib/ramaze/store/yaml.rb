#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'yaml/store'
require 'fileutils'
require 'set'

module Ramaze::Store
  module YAML
    def self.new(*args)
      Manager.new(*args)
    end

    class YAMLStoreWrapper

      # pass on all methods inside a transaction

      def method_missing(meth, *args, &block)
        @entities.transaction do
          @entities.send(meth, *args, &block)
        end
      end

      # yield a block in a transaction, identical to #db.transaction{}

      def transaction
        @entities.transaction do
          yield(@entities)
        end
      end

      def to_yaml
        @entities.dump(:x)
      end

      # loads the #to_yaml

      def original
        ::YAML.load(to_yaml)
      end

      # available keys of the store

      def keys
        (original || {}).keys
      end

      # is the Store empty? (no keys)

      def empty?
        keys.empty?
      end

      def [](eid)
        transaction do |e|
          e[eid.to_s.to_sym]
        end
      end

      def []=(eid, entity)
        transaction do |e|
          e[eid.to_s.to_sym] = entity
        end
      end

      def each
        original.each do |key, value|
          yield key, value
        end
      end
    end

    class Manager < YAMLStoreWrapper
      attr_accessor :store, :store_filename, :store_name, :entities

      def initialize name, options = {}
        @store_name = name
        @store_filename = "#{@store_name}.yaml"

        FileUtils.rm_f(@store_filename) if options[:destroy]

        @entities = ::YAML::Store.new(@store_filename)
      end

      def new
        entity = Entity.new
        entity.instance_variable_set('@manager', self)
        entity
      end

      def next_eid
        (keys.max || '`').next
      end

      def store entity
        if entity.eid
          self[entity.eid] = entity
        else
          eid = next_eid
          entity.eid = eid
          self[entity.eid] = entity
        end
      end
    end

    class Entity < OpenStruct
      attr_accessor :manager
      trait :no_properties => Set.new(%w[ manager ])

      def save
        our_name = self.manager.store_name
        @table.each do |key, value|
          if value.respond_to?(:save) and value.send(our_name) != self
            value.send("#{our_name}=", self)
            value.save
          end
        end
        @manager.store self
      end

      def to_yaml_properties
        instance_variables - self.class.ancestral_trait[:no_properties].map{|np| "@#{np}"}
      end
    end
  end
end
