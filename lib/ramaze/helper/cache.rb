#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module Helper

    # Caching of simple objects and whole action responses.
    module Cache

      # Setup needed traits, add the singleton methods and add the caches used
      # by this helper.
      #
      # @param [Class] into Class that this Module is included into
      # @author manveru
      def self.included(into)
        into.extend(SingletonMethods)
        into.trait[:wrap] ||= [:aspect_wrap, :cache_wrap]
        into.trait[:cache_action] ||= Set.new
        Ramaze::Cache.add(:action, :action_value)
      end

      # @param [Action] action The currently wrapped action
      # @yield The next block in wrap_action_call
      # @return [String] the response body
      # @see Innate::Node#wrap_action_call
      # @author manveru
      def cache_wrap(action)
        cache = Innate::Cache.action

        ancestral_trait[:cache_action].each do |cache_action|
          temp = cache_action.dup
          ttl = temp.delete(:ttl)

          if temp.all?{|key, value| action[key] == value }
            if cached = cache[temp]
              return cached
            elsif ttl
              return cache.store(temp, yield, :ttl => ttl)
            else
              return cache.store(temp, yield)
            end
          end
        end

        yield
      end

      # @return [Object] The cache wrapper assigned for :action_value
      # @see Innate::Cache
      # @author manveru
      def cache_value
        Ramaze::Cache.action_value
      end


      # @deprecated Use the #cache_value method instead
      # @author manveru
      def value_cache
        Ramaze::deprecated('Innate::Helper::Cache#value_cache',
                           'Innate::Helper::Cache#cache_value')
        cache_value
      end

      module SingletonMethods
        def cache(name, hash = {})
          Ramaze.deprecated('Helper::Cache::cache', 'Helper::Cache::cache_action')
          cache_action(hash.merge(:method => name))
        end

        def cache_action(hash)
          hash[:method] = hash[:method].to_s
          trait[:cache_action] << hash
        end
      end
    end
  end
end
