#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    class << self
      def render(action = {})
        action = Action.fill(action) if action.is_a?(Hash)
        Inform.debug("The Action: #{action}")

        action.method = action.method.to_s
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
        controller.instance_variable_set('@action', action.method)
        Thread.current[:controller] = controller

        options = {
          :file       => action.template,
          :binding    => controller.instance_eval{ binding },
          :action     => action.method,
          :parameter  => action.params,
        }

        engine = select_engine(options[:file])
        engine.transform(controller, options)
      end

      def cached_render action
        action_cache = Controller.trait[:action_cache]

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

        engines = Controller.trait[:template_extensions]
        return default if engines.empty?

        ext = File.extname(file).gsub(/^\./, '')
        ext_engine = engines[ext]
        return ext_engine ? ext_engine : default
      end

      # This method is called by templating-engines to register themselves with
      # a list of extensions that will be looked up on #render of an action.

      def register_engine engine, *extensions
        extensions.flatten.each do |ext|
          trait[:template_extensions][ext] = engine
        end
      end
    end
  end
end
