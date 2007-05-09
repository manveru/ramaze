#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template'

module Ramaze

  Action = Struct.new('Action', :template, :method, :params)

  # The Controller is responsible for combining and rendering actions.

  class Controller
    include Ramaze::Helper
    extend Ramaze::Helper

    helper :redirect, :link, :file

    trait :template_extensions => { }

    # Path to the ramaze-internal public directory for error-pages and the like.
    # It acts just as a shadow.
    trait :ramaze_public => ( ::Ramaze::BASEDIR / 'proto' / 'public' )

    # Whether or not to map this controller on startup automatically

    trait :automap => true

    # Place to map the Controller to, this is something like '/' or '/foo'

    trait :map => nil

    trait :exclude_action_modules => [Kernel, Object, PP::ObjectMixin]

    class << self
      include Ramaze::Helper
      extend Ramaze::Helper

      def inherited controller
        Global.controllers << controller
      end

      def validate_sanity
        if path = trait[:public]
          unless File.directory?(path)
            Inform.warn("#{controller} uses templating in #{path}, which does not exist")
          end
        end
      end

      def mapping
        global_mapping = Global.mapping.invert[self]
        return global_mapping if global_mapping
        if map = class_trait[:map]
          map
        elsif ancestral_trait[:automap]
          name = self.to_s.gsub('Controller', '').split('::').last
          %w[Main Base Index].include?(name) ? '/' : "/#{name.snake_case}"
        end
      end

      def map(*syms)
        syms.each do |sym|
          Global.mapping[sym.to_s] = self
        end
      end

      def handle path
        controller, action = *resolve(path)
        controller.render(action)
      end

      def resolve(path)
        #Inform.debug("resolve_controller('#{path}')")
        mapping     = Global.mapping
        controllers = Global.controllers

        raise_no_controller(path) if controllers.empty? or mapping.empty?

        class_trait[:pattern_for] ||= Hash.new{|h,k| h[k] = pattern_for(k)}

        class_trait[:pattern_for][path].each do |controller, method, params|
          if controller = mapping[controller]
            action = controller.resolve_action(method, *params)
            template = action.template
            action.method ||= File.basename(template, File.extname(template)) if template
            p action
            return controller, action if action.method
          end
        end

        raise_no_controller(path)
      end

      def resolve_action(path, *parameter)
        possible_path = trait["#{path}_template".to_sym]
        template = resolve(possible_path).last.template if possible_path

        method, params = resolve_method(path, *parameter)

        if method or parameter.empty?
          template ||= resolve_template(path)
        end

        Action.new(template, method, params)
      end

      def resolve_template(action)
        paths = (class_trait[:template_paths] ||= template_paths)
        exts = extension_order

        regexp = action.split(/\/|__/).map{|s| Regexp.escape(s) }
        regexp = /\/+#{regexp.join('(?:\/|__)')}(#{exts.join('|')})$/
        paths = paths.grep(regexp).sort_by{|path| exts.index(File.extname(path))}

        exclude = [Kernel, Object, PP::ObjectMixin]

          return path unless path_base.empty?
        end

        nil
      end

      def template_paths
        klass_public = trait[:public]
        ramaze_public = Controller.trait[:ramaze_public]

        first_path =
          if template_root = class_trait[:template_root]
            template_root
          else
            Global.template_root / Global.mapping.invert[self]
          end
        paths = [ first_path, klass_public, ramaze_public].compact

        glob = "{#{paths.join(',')}}/**/*"

        Dir[glob].select{|f| File.file?(f)} #.map{|f| File.expand_path(f)}
      end

      def resolve_method(name, *params)
        if method = action_methods.delete(name)
          arity = instance_method(method).arity
          if params.size == arity or arity < 0
            return method, params
          end
        end
        return nil, []
      end

      def action_methods
        exclude = Controller.trait[:exclude_action_modules]

        ancs = (ancestors - exclude).select{|a| a.is_a?(Module)}
        ancs.map{|a| a.instance_methods(false).map(&:to_s)}.flatten.uniq
      end

      def pattern_for(path)
        atoms = path.split('/').grep(/\S/)
        atoms.unshift('')
        patterns, joiners = [], ['/']

        atoms.size.times do |enum|
          enum += 1
          joiners << '__' if enum == 3

          joiners.each do |joinus|
            pattern = atoms.dup

            controller = pattern[0, enum].join(joinus)
            controller.gsub!(/^__/, '/')
            controller = "/" if controller == ""

            pattern = pattern[enum..-1]
            args, temp = [], []

            patterns << [controller, 'index', atoms[enum..-1]]

            until pattern.empty?
              args << pattern.shift
              patterns << [controller, args.join( '__' ), pattern.dup]
            end
          end
        end

        patterns.reverse!
      end

      def extension_order
        t_extensions = Controller.trait[:template_extensions]
        engine = trait[:engine]
        c_extensions = t_extensions.reject{|k,v| v != engine}.keys
        all_extensions = t_extensions.keys
        (c_extensions + all_extensions).uniq.map{|e| ".#{e}"}
      end

      def render(action = {})
        action = Action.new(action.values_at(:template, :method, :params)) if action.is_a?(Hash)
        action.method = action.method.to_s
        trait[:actions_cached] ||= Set.new

        cache_indicators = [
          Global.cache_all,
          class_trait[:cache_all],
          class_trait[:actions_cached].map{|k| k.to_s}.include?(action.method),
        ]

        if cache_indicators.any?
          cached_render(action)
        else
          uncached_render(action)
        end
      end

      def uncached_render(action)
        controller = self.new
        controller.instance_variable_set('@action', action.method)

        file   = action.template
        engine = select_engine(file)
        parameter = action.params

        options = {
          :file       => file,
          :binding    => controller.instance_eval{ binding },
          :action     => action.method,
          :parameter  => parameter.compact,
        }

        engine.transform(controller, options)
      end

      def cached_render action
        trait[:action_cache] ||= Global.cache.new

        if out = class_trait[:action_cache][action]
          Inform.debug("Using Cached version for #{action}")
          return out
        end

        Inform.debug("Compiling Action: #{action}")
        class_trait[:action_cache][action] = uncached_render(action)
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

      def raise_no_controller(path)
        raise Ramaze::Error::NoController, "No Controller found for `#{path}'"
      end

      def raise_no_action(controller, path)
        raise Ramaze::Error::NoAction, "No Action found for `#{path}' on #{controller}"
      end
    end

    # the default error-page handler. you can overwrite this method
    # in your controller and create your own error-template for use.
    #
    # Error-pages can be in whatever the templating-engine of your controller
    # is set to.
    #   Thread.current[:exception]
    # holds the exception thrown.

    def error
      error = Thread.current[:exception]
      @backtrace = error.backtrace[0..20]
      title = error.message

      @colors = []
      min = 200
      max = 255
      step = -((max - min) / @backtrace.size).abs
      max.step(min, step) do |color|
        @colors << color
      end

      backtrace_size = Ramaze::Global.backtrace_size

      @backtrace.map! do |line|
        file, lineno, meth = *Ramaze.parse_backtrace(line)
        lines = Ramaze.caller_lines(file, lineno, backtrace_size)

        [ lines, lines.object_id.abs, file, lineno, meth ]
      end

      @title = CGI.escapeHTML(title)
      require 'coderay'
      @coderay = true
      title
    rescue LoadError => ex
      @coderay = false
      title
    rescue Object => ex
      Inform.error(ex)
    end

    private

    def render *args
      self.class.handle(*args)
    end
  end
end
