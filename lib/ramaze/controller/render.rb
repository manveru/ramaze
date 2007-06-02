#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    class << self

      # Entering point from Controller::handle(path)
      # takes an Hash or Action and goes on to determine whether this action is
      # cached. Depending on that it will call either
      # Controller::cached_render(action) or Controller::uncached_render(action)

      def render(action = {})
        action = Action.fill(action) if action.is_a?(Hash)
        Inform.debug("The Action: #{action}")

        action.method = action.method.to_s if action.method
        action.params ||= []
        action.params.compact!

        if cached?(action)
          cached_render(action)
        else
          uncached_render(action)
        end
      end

      # Checks whether an action is cached, please see the source for the exact
      # criteria.

      def cached?(action)
        actions_cached = trait[:actions_cached]

        [ Global.cache_all,
          trait[:cache_all],
          actions_cached.map{|k| k.to_s}.include?(action.method),
        ].any?
      end

      # Completes the Action with binding and controller, sets
      # Thread.current[:controller] for Controller::current.
      # Then calls before_process/after_process so AspectHelper can hook into
      # them (otherwise they just return empty strings, and builds a body based
      # on that.
      # In between of these hooks it will determine the engine to use over
      # select_engine(action.template) and call ::transform(action) on it.

      def uncached_render(action)
        controller = self.new
        controller.instance_variable_set('@action', action)
        Thread.current[:controller] = controller

        action.binding = controller.instance_eval{ binding }
        action.controller = controller

        before = before_process(action)

        engine = select_engine(action.template)
        answer = engine.transform(action)

        after = after_process(action)
        [before, answer, after].join
      end

      # Hook for AspectHelper

      def before_process(action)
        ''
      end

      # Hook for AspectHelper

      def after_process(action)
        ''
      end

      # Gets the action from Cache.actions and fills it up with
      # uncached_render(action) if none is set yet.
      # Returns the result of the first request for an action ever made.

      def cached_render action
        action_cache = Cache.actions

        if out = action_cache[action]
          Inform.debug("Using Cached version for #{action}")
          return out
        end

        Inform.debug("Compiling Action: #{action}")
        action_cache[action] = uncached_render(action)
      end

      # Determines based on trait :engine and the template extensions which
      # engine a template or Controller has to be processed with.

      def select_engine(file)
        trait_engine = class_trait[:engine]
        default = [trait_engine, Template::Ezamar].compact.first
        return default unless file

        engines = Controller::TEMPLATE_ENGINES
        return default if engines.empty?

        ext = File.extname(file).gsub(/^\./, '')
        ext_engine = engines.find{|e| e.last.include?(ext)}.first
        return ext_engine ? ext_engine : default
      end

      # This method is called by templating-engines to register themselves with
      # a list of extensions that will be looked up on Controller::uncached_render

      def register_engine engine, *extensions
        TEMPLATE_ENGINES << [engine, extensions.flatten.uniq.compact]
      end
    end
  end
end
