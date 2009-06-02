#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'sequel'

module Ramaze
  class Cache

    # Cache based on a Sequel model using relational databases.
    #
    # Please note that this cache might not work perfectly with Sequel 3.0.0,
    # as the #[] and #[]= methods do not respect serialization.
    # I'll lobby for a change in that direction.
    class Sequel
      include Cache::API

      class Table < ::Sequel::Model(:ramaze_cache)
        plugin :schema
        plugin :serialization

        serialize_attributes :marshal, :value

        set_schema do
          primary_key :id
          index :key, :unique => true

          String :key
          String :value
          Time :expires
        end

        def [](column)
          if column == :value
            deserialized_values[column] = deserialize_value(column, @values[column])
          else
            super
          end
        end
      end

      # Setup the table, not suitable for multiple apps yet.
      def cache_setup(host, user, app, name)
        @namespace = [host, user, app, name].compact.join(':')
        Table.create_table?
        @store = Table
      end

      # Wipe out _all_ data in the table, use with care.
      def cache_clear
        Table.delete
      end

      # Delete records for given +keys+
      def cache_delete(*keys)
        super do |key|
          record = @store[:key => namespaced(key)]
          record.delete if record
        end
      end

      def cache_fetch(key, default = nil)
        super{|key| @store[:key => namespaced(key)] }
      end

      def cache_store(key, value, options = {})
        key = namespaced(key)
        ttl = options[:ttl]
        expires = Time.now + ttl if ttl

        record = @store[:key => key].update(:value => value, :expires => expires)
        record.value
      rescue
        record = @store.create(:key => key, :value => value, :expires => expires)
        record.value
      end

      def namespaced(key)
        [@namespace, key].join(':')
      end
    end
  end
end
