#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Cache

    # Cache based on a Sequel model using relational databases.
    class Sequel
      include Cache::API

      class Table < ::Sequel::Model(:ramaze_cache)
        set_schema do
          primary_key :id
          string :key
          string :value
          time :expires
          index :key, :unique => true
        end

        transform :value => [
          lambda{|value| ::Marshal.load(value.unpack('m*')[0]) },
          lambda{|value| [::Marshal.dump(value)].pack('m*') }
        ]
      end

      # Setup the table, not suitable for multiple apps yet.
      def cache_setup(host, user, app, name)
        @namespace = [host, user, app, name].compact.join(':')
        Table.create_table unless Table.table_exists?
        @store = Table
      end

      # Wipe out _all_ data in the table, use with care.
      def cache_clear
        Table.delete_all
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
