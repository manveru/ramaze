# drop-in replacement for Ramaze's built-in MemoryCache built on the Sequel.
# to use with sessions do
#
#   Ramaze::Global::cache_alternative[:sessions] = Ramaze::SequelCache
#
# to use with everything do
#
#   Ramaze::Global::cache = Ramaze::SequelCache
#

module Ramaze
  class Cache
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

      # setup the table, not suitable for multiple apps yet.
      def cache_setup(host, user, app, name)
        @namespace = [host, user, app, name].compact.join(':')
        Table.create_table unless Table.table_exists?
        @store = Table
      end

      def cache_clear
        Table.delete_all
      end

      def cache_delete(*keys)
        super do |key|
          record = @store[:key => namespaced(key)]
          record.delete if record
        end
      end

      def cache_fetch(key, default = nil)
        super do |key|
          @store[:key => namespaced(key)]
        end
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
