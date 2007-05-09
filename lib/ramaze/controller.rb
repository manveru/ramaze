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
        controller, action, params = *resolve_controller(path)
        controller = self unless controller
        controller.render action, *params
      end

      # find out which controller should be used based on the path.
      # it will answer [controller, action, params] or raise an
      #
      #   Ramaze::Error::NoController # if no controller is found
      #   Ramaze::Error::NoAction     # if no action but a controller is found
      #
      # It actually uses #resolve_action on almost every combination of
      # so-called paractions (yet unsplit but possible combination of action
      # and parameters for the action)
      #
      # If your templating is action-less, which means it does not depend on
      # methods on the controller, but rather on templates or just dynamically
      # calculated stuff you can set trait[:actionless] for your templating.
      #
      # Please see the documentation for Ramaze::Template::Amrita2 for an more
      # specific example of how it is used in practice.
      #
      # Further it uses the Global.mapping to look up the controller to be used.
      #
      # Also, the action '/' will be expanded to 'index'
      #
      # Parameters are CGI.unescaped

      def resolve_controller(path)
        Inform.debug("resolve_controller(#{path.inspect})")
        track = path.split('/')
        track.delete('')
        mapping = Ramaze::Global.mapping
        controller = false
        action = false
        slash_tracks = []
        down_tracks = []

        track.each do |atom|
          slash_tracks << "#{slash_tracks.last}/#{atom}"
          down_tracks << "#{down_tracks.last}__#{atom}"
        end

        down_tracks.shift

        tracks = ['/'] + slash_tracks + down_tracks

        until controller and action or tracks.empty?
          current = Regexp.escape(tracks.pop.to_s)
          if controller = mapping[current]
            paraction = path.gsub(/^#{current}/, '').split('/').map{|e| CGI.unescape(e)}
            paraction.delete('')
            action, params = resolve_action(controller, paraction)
          end
        end

        raise_no_controller(path) unless controller
        raise_no_action(controller, path) unless action

        return controller, action, params
      end

      # Resolve the method to be called and the number of parameters
      # it will receive for a specific class (the controller) given the
      # paraction (like 'foo/bar' => controller.call('foo', 'bar'))
      # in case arity is 1 and a public instance-method named foo is defined.
      #
      # TODO:
      # - find a solution for def x(a = :a) which has arity -1
      #   identical to def x(*a) for some odd reason

      def resolve_action(controller, paraction)
        Inform.debug("resolve_action(#{controller.inspect}, #{paraction.inspect})")

        exclude = [Kernel, Object, PP::ObjectMixin]

        if defined?(::Spec)
          exclude += [Base64::Deprecated, Base64, Spec::Expectations::ObjectExpectations]
        end

        ancs = (controller.ancestors - exclude).select{|a| a.is_a?(Module)}
        meths = ancs.map{|a| a.instance_methods(false).map(&:to_s)}.flatten.uniq

        track = paraction.dup
        tracks = []
        action = false

        track.each do |atom|
          atom = [tracks.last.to_s, atom]
          atom.delete('')
          tracks << atom.join('__')
        end

        tracks.unshift 'index'

        until action or tracks.empty?
          current = tracks.pop
          if meths.include?(current) #or current = controller.class_trait[:template_map][current]
            arity = controller.instance_method(current).arity
            params = (paraction - current.split('__'))

            if params.size == arity
              return current, params
            elsif arity < 0
              return current, params
            end
          elsif file = find_template(current, controller)
            return current, params
          end
        end
      end

      # The universal #render method that has to be provided by every
      # prospective Controller, pass it your action and parameters.
      #
      # This is called upon by the Dispatcher, but you can use it in your
      # Controller/View to get the contents of another action.
      #
      # It will set the instance-variable @action in the instance of itself
      # to the value of the current action.

      def render action, *parameter
        trait[:actions_cached] ||= Set.new

        cache_indicators = [
          Global.cache_all,
          class_trait[:cache_all],
          class_trait[:actions_cached].map{|k| k.to_s}.include?(action.to_s),
        ]

        if cache_indicators.any?
          cached_render(action, *parameter)
        else
          uncached_render(action, *parameter)
        end
      end

      def uncached_render action, *parameter
        controller = self.new
        controller.instance_variable_set('@action', action)

        file   = find_template(action)
        engine = select_engine(file)

        options = {
          :file       => file,
          :binding    => controller.instance_eval{ binding },
          :action     => action,
          :parameter  => parameter.compact,
        }
        engine.transform(controller, options)
      end

      def cached_render action, *parameter
        key = [action, parameter].inspect

        trait[:action_cache] ||= Global.cache.new

        if out = class_trait[:action_cache][key]
          Inform.debug("Using Cached version for #{key}")
          return out
        end

        Inform.debug("Compiling Action: #{action} #{parameter.join(', ')}")
        class_trait[:action_cache][key] = uncached_render(action, *parameter)
      end

      # This finds the template for the given action on the current controller
      # there are some basic ways how you can provide an alternative path:
      #
      # Global.template_root = 'default/path'
      #
      # class FooController < Controller
      #   trait :template_root => 'another/path'
      #   trait :index_template => :foo
      #
      #   def index
      #   end
      # end
      #
      # One feature also used in the above example is the custom template for
      # one action, in this case :index - now the template of :foo will be
      # used instead.

      def find_template action, klass = self
        custom_template = class_trait["#{action}_template".intern]
        action = (custom_template ? custom_template : action).to_s
        action_converted = action.split('__').inject {|s,v| "#{s}/#{v}"}
        klass_public = klass.trait[:public]
        ramaze_public = Controller.trait[:ramaze_public]

        first_path =
          if template_root = klass.class_trait[:template_root]
            template_root
          else
            Global.template_root / Global.mapping.invert[self]
          end

        actions = [action, action_converted].compact
        all_paths = [ first_path, klass_public, ramaze_public].compact
        paths = all_paths.map{|pa| actions.map{|a| File.expand_path(pa / a) } }.flatten.uniq

        glob = "{#{paths.join(',')}}.{#{extension_order.join(',')}}"

        possible = Dir[glob]
        possible.first
      end

      def extension_order
        t_extensions = Controller.trait[:template_extensions]
        engine = trait[:engine]
        c_extensions = t_extensions.reject{|k,v| v != engine}.keys
        all_extensions = t_extensions.keys
        (c_extensions + all_extensions).uniq
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

      def raise_no_action(controller, action)
        raise Ramaze::Error::NoAction, "No Action found for `#{action}' on #{controller}"
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
