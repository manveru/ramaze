#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  module CacheHelper

    # Cache for single key/value pairs

    trait :value_cache  => Global.cache.new

    # Cache for values returned from actions

    trait :action_cache => Global.cache.new

    private

    # use this to cache values in your controller and templates,
    # for example heavy calculations or time-consuming queries.

    def value_cache
      ancestral_trait[:value_cache]
    end

    # holds the values returned on the first call to a cached action.
    # To uncache, simply delete.
    #
    # Please note that the action is cached by a combination of
    # [action, parameter].inspect - so it is a bit awkward to use.
    #
    # Suggestions welcome.
    #
    # Example:
    #
    #   action_cache.delete '["index", []]'
    #
    # or by delete_if
    #
    #   action_cache.delete_if{|key, value| key =~ /"index",/}

    def action_cache
      ancestral_trait[:action_cache]
    end

    # This refers to the class-trait of cached actions, you can
    # add/remove actions to be cached.
    #
    # Example:
    #
    #   class FooController < Ramaze::Controller
    #     trait :actions_cached => [:index, :map_of_the_internet]
    #   end

    def actions_cached
      ancestral_trait[:actions_cached]
    end
  end
end
