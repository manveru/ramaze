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
      if Global.action_file_cached
        epath = extended_path
        File.open(epath, 'w+'){|fp| fp.puts(uncached_render) } unless File.file?(epath)
        File.read(epath)
      else
        action_cache = Cache.actions

        if out = action_cache[relaxed_hash]
          Inform.debug("Using Cached version")
          return out
        end

        Inform.debug("Compiling Action")
        action_cache[relaxed_hash] = uncached_render
      end
    end

    # The 'normal' rendering process. Passes the Action instance to
    # Action#engine.transform, which returns the output of the action.
    # Layout will be found and rendered in this step after self was rendered.

    def uncached_render
      bp = before_process
      content = engine.transform(self)
      ap = after_process

      if tlayout = layout
        instance.instance_variable_set("@content", content)
        content = tlayout.render
        Thread.current[:action] = self
      end
      [bp, content, ap].join
    end

    # Determine whether or not we have a layout to process and sets it up
    # correctly to be rendered in the same context as current action.
    # Will return false if the layout is the same as current action to avoid
    # infinite recursion and also if no layout on this controller was found.

    def layout
      return false unless layouts = controller.trait[:layout]

      possible = [layouts[:all], layouts[path]].compact
      denied = layouts[:deny].to_a

      if layout = possible.first
        layout_action = Ramaze::Controller.resolve(layout)

        if denied.include?(path) or layout_action.path == path
          return false
        end

        layout_action.binding = binding
        layout_action.controller = controller
        layout_action.instance = instance
        layout_action
      end
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
