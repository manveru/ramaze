#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module CacheHelper
    trait :value_cache  => Global.cache.new
    trait :action_cache => Global.cache.new

    private

    def value_cache
      ancestral_trait[:value_cache]
    end

    def action_cache
      ancestral_trait[:action_cache]
    end

    def actions_cached
      ancestral_trait[:actions_cached]
    end
  end
end
