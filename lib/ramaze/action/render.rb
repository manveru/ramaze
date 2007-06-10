#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Action
    def render
      Inform.debug("The Action: #{self}")
      Thread.current[:action] = self

      if should_cache?
        cached_render
      else
        uncached_render
      end
    end

    def cached_render
      action_cache = Cache.actions

      if out = action_cache[relaxed_hash]
        Inform.debug("Using Cached version")
        return out
      end

      Inform.debug("Compiling Action")
      action_cache[relaxed_hash] = uncached_render
    end

    def uncached_render
      [ before_process,
        engine.transform(self),
        after_process,
      ].join
    end

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
