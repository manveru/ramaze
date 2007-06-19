#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Action

    # Render this instance of Action, this will (eventually) pass itself to
    # Action#engine.transform
    # Usage, given that Foo is a Controller and has the method/template
    # for index:
    #  > Action(:controller => Foo).render
    #  #> 'bar'

    def render
      Inform.debug("The Action: #{self}")
      Thread.current[:action] = self

      if should_cache?
        cached_render
      else
        uncached_render
      end
    end

    # Return the cached output of the action if it exists, otherwise do a
    # normal Action#uncached_render and store the output in the Cache.actions.
    # Action#cached_render is only called if Action#should_cache? returns
    # true.

    def cached_render
      action_cache = Cache.actions

      if out = action_cache[relaxed_hash]
        Inform.debug("Using Cached version")
        return out
      end

      Inform.debug("Compiling Action")
      action_cache[relaxed_hash] = uncached_render
    end

    # The 'normal' rendering process. Passes the Action instance to
    # Action#engine.transform, which returns the output of the action.

    def uncached_render
      [ before_process,
        engine.transform(self),
        after_process,
      ].join
    end

    # return true if the action is flagged for caching. Called by
    # Action#render.

    def should_cache?
      ctrait = controller.trait
      actions_cached = ctrait[:actions_cached]

      [ Global.cache_all,
        ctrait[:cache_all],
        actions_cached.map{|k| k.to_s}.include?(method),
      ].any?
    end
  end
end
