#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template'

module Ramaze

  class Action < Struct.new('Action', :method, :params, :template)
    def to_s
      %{#<Action method=#{method.inspect}, params=#{params.inspect} template=#{template.inspect}>}
    end
  end

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

    trait :pattern_cache => Hash.new{|h,k| h[k] = Controller.pattern_for(k) }

    trait :action_cache  => Global.cache.new

    class << self
      include Ramaze::Helper
      extend Ramaze::Helper

      def inherited controller
        controller.trait :actions_cached => Set.new
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

      def current
        Thread.current[:controller]
      end

      def handle path
        controller, action = *resolve(path)
        controller.render(action)
      end


      # #ramaze - 9.5.2007
      #
      # manveru    | if no possible controller is found, it's a NoController error
      # manveru    | that would be a 404 then
      # Kashia     | aye
      # manveru    | if some controller are found but no actions on them, it's NoAction Error for the first controller found, again, 404
      # manveru    | everything further down is considered 500

      def resolve(path)
        #Inform.debug("resolve_controller('#{path}')")
        mapping     = Global.mapping
        controllers = Global.controllers

        raise_no_controller(path) if controllers.empty? or mapping.empty?

        patterns = Controller.trait[:pattern_cache][path]
        first_controller = nil

        patterns.each do |controller, method, params|
          if controller = mapping[controller]
            first_controller ||= controller

            action = controller.resolve_action(method, *params)
            template = action.template

            action.method ||= File.basename(template, File.extname(template)) if template

            return controller, action if action.method
          end
        end

        raise_no_action(first_controller, path) if first_controller
        raise_no_controller(path)
      end

      def resolve_action(path, *parameter)
        path, parameter = path.to_s, parameter.map(&:to_s)
        possible_path = trait["#{path}_template".to_sym]
        template = resolve(possible_path).last.template if possible_path

        method, params = resolve_method(path, *parameter)

        if method or parameter.empty?
          template ||= resolve_template(path)
        end

        Action.new(method, params, template)
      end

      def resolve_template(action)
        action = action.to_s
        action_converted = action.split('__').inject{|s,v| s/v}
        actions = [action, action_converted].compact

        paths = template_paths.map{|pa| actions.map{|a| pa/a } }.flatten.uniq
        glob = "{#{paths.join(',')}}.{#{extension_order.join(',')}}"

        Dir[glob].first
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
        [ first_path, klass_public, ramaze_public].compact
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
        meths = ancs.map{|a| a.instance_methods(false).map(&:to_s)}.flatten.uniq
        # fix for facets/more/paramix
        meths - ancs.map(&:to_s)
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
        (c_extensions + all_extensions).uniq
      end

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
