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
      Inform.dev("The Action: #{self}")
      Thread.current[:action] = self

      if should_cache?
        cached_render
      else
        uncached_render
      end
    end

    private

    # Return the cached output of the action if it exists, otherwise do a
    # normal Action#uncached_render and store the output in the Cache.actions.
    # Action#cached_render is only called if Action#should_cache? returns
    # true.

    def cached_render
      if Global.file_cache
        cached_render_file
      else
        cached_render_memory
      end
    end

    def cached_render_file
      rendered = uncached_render

      global_epath = Global.public_root/self.controller.mapping/extended_path
      FileUtils.mkdir_p(File.dirname(global_epath))
      File.open(global_epath, 'w+') {|fp| fp.print(rendered) }

      rendered
    end

    def cached_render_memory
      action_cache = Cache.actions
      full_path = self.controller.mapping/extended_path

      # backwards compat with trait :actions_cached => []
      cache_opts = actions_cached.is_a?(Hash) ? actions_cached[path.to_sym] : {}

      if cache_opts[:key]
        action_cache[full_path] ||= {}
        cache = action_cache[full_path][ cache_opts[:key].call ] ||= {}
      else
        cache = action_cache[full_path] ||= {}
      end

      if cache.size > 0 and (cache_opts[:ttl].nil? or cache[:time] + cache_opts[:ttl] > Time.now)
        Inform.debug("Using Cached version")
        Response.current['Content-Type'] = cache[:type]
      else
        Inform.debug("Compiling Action")
        cache.replace({ :time => Time.now, :content => uncached_render, :type => Response.current['Content-Type'] })
      end

      cache[:content]
    end

    # The 'normal' rendering process. Passes the Action instance to
    # Action#engine.transform, which returns the output of the action.
    # Layout will be found and rendered in this step after self was rendered.

    def uncached_render
      content = [before_process,
                 engine.transform(self),
                 after_process].join

      if path and tlayout = layout
        instance.instance_variable_set("@content", content)
        content = tlayout.render

        # restore Action.current after render above
        Thread.current[:action] = self
      end

      content
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
        layout_action.path = nil
        layout_action
      end
    end

    def actions_cached
      controller.trait[:actions_cached]
    end

    # return true if the action is flagged for caching. Called by
    # Action#render.

    def should_cache?
      ctrait = controller.trait

      [ Global.cache_all,
        ctrait[:cache_all],
        actions_cached.map{|k,v| k.to_s}.include?(method),
      ].any?
    end
  end
end
