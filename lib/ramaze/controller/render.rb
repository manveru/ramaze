#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    class << self
      def render(action = {})
        action = Action.fill(action) if action.is_a?(Hash)
        Inform.debug("The Action: #{action}")

        action.method = action.method.to_s if action.method
        action.params.compact!

        if cached?(action)
          cached_render(action)
        else
          uncached_render(action)
        end
      end

      def cached?(action)
        actions_cached = trait[:actions_cached]

        [ Global.cache_all,
          trait[:cache_all],
          actions_cached.map{|k| k.to_s}.include?(action.method),
        ].any?
      end

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

      def before_process(action)
        ''
      end

      def after_process(action)
        ''
      end

      def cached_render action
        action_cache = Cache.actions

        if out = action_cache[action]
          Inform.debug("Using Cached version for #{action}")
          return out
        end

        Inform.debug("Compiling Action: #{action}")
        action_cache[action] = uncached_render(action)
      end

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
      # a list of extensions that will be looked up on #render of an action.

      def register_engine engine, *extensions
        TEMPLATE_ENGINES << [engine, extensions.flatten.uniq.compact]
      end
    end
  end
end
