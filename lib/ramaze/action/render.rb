#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Action

    # Use your block and jump into the Action::stack - this allows you to call
    # nested actions.
    def stack
      Action.stack << self
      yield self
    rescue Object => ex
      Log.error "#{ex} in: #{self}"
      raise ex
    ensure
      Action.stack.pop
    end

    # Render this instance of Action, this will (eventually) pass itself to
    # Action#engine.transform
    # Usage, given that Foo is a Controller and has the method/template
    # for index:
    #  > Action(:controller => Foo).render
    #  #> 'bar'

    def render
      Log.dev("Action: #{self}")

      stack do
        if should_cache?
          cached_render
        else
          uncached_render
        end
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
        Log.debug("Using Cached version")
        Response.current['Content-Type'] = cache[:type]
      else
        Log.debug("Compiling Action")
        cache.replace({ :time => Time.now, :content => uncached_render, :type => Response.current['Content-Type'] })
      end

      cache[:content]
    end

    # The 'normal' rendering process. Passes the Action instance to
    # Action#engine.transform, which returns the output of the action.
    # Layout will be found and rendered in this step after self was rendered.

    def uncached_render
      before_process

      content = engine.transform(self)

      if path and tlayout = layout
        [instance, tlayout.instance].each do |i|
          i.instance_variable_set("@content", content)
        end

        content = tlayout.render
      end

      content

    ensure
      after_process unless $!
    end

    # Determine whether or not we have a layout to process and sets it up
    # correctly to be rendered in the same context as current action.  Will
    # return false if the layout is the same as current action to avoid
    # infinite recursion and also if no layout on this controller or its
    # ancestors was found.

    def layout
      return false unless layouts = controller.ancestral_trait[:layout]

      possible = [layouts[path], layouts[:all]].compact
      denied = layouts[:deny].to_a

      if layout = possible.first
        if layout.to_s !~ /\A\// # late bind layout action to current controller
          layout = R(controller, layout)
        end
        layout_action = Controller.resolve(layout)

        return false if denied.any?{|deny| deny === path} or layout_action.path == path

        if layout_action.controller != controller
          instance.instance_variables.each do |x|
            if layout_action.instance.instance_variable_defined?(x)
              Log.warn "overwriting instance variable #{x} from layout controller with instance variable from action controller."
            end
            layout_action.instance.instance_variable_set(x, instance.instance_variable_get(x))
          end
        else
          layout_action.binding = binding
          layout_action.controller = controller
          layout_action.instance = instance
        end

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
