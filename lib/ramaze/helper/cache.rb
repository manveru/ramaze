#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
module Ramaze
  module CacheHelper
    private

    # a simple cache for values based on Global.cache

    def value_cache
      @@cache ||= Global.cache.new
    end

    # forget about one cached action

    def uncache action
      Global.cached_actions[self.class].each do |e|
        e.include?(action.to_s)
      end
    end

    # uncache all actions

    def uncache_all
      Global.cached_actions.delete(self.class)
    end
    alias uncache_all_actions uncache_all

    # cache all given methods

    def cache(*actions)
      self.class.cache(*actions)
    end
    alias cache_actions cache

    # define the cache class-method on inclusion

    def self.included(klass)
      klass.class_eval do
        class << self

          # mark actions for caching

          def cache(*actions)
            Global.cache_actions[self].merge(*actions.flatten.map{|a| a.to_s })
          end
          alias cache_actions cache

        end
      end
    end
  end
end
