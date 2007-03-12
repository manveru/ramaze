#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/template'

module Ramaze

  # The Controller is responsible for combining and rendering actions.

  class Controller
    include Ramaze::Helper
    extend Ramaze::Helper

    helper :redirect, :link

    trait :template_extensions => { }

    # Path to the ramaze-internal public directory for error-pages and the like.
    # It acts just as a shadow.
    trait :public => ( ::Ramaze::BASEDIR / 'proto' / 'public' )

    class << self
      include Ramaze::Helper
      extend Ramaze::Helper

      def handle path
        controller, action, params = *resolve_controller(path)
        action, params = path.gsub(/^\//, '').split('/').join('__'), [] unless action
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

      def resolve_controller path
        Informer.meth_debug :resolve_controller, path
        track = path.split('/')
        controller = false
        action = false
        tracks = []

        track.unshift '/'

        track.each do |atom|
          tracks << (tracks.last.to_s / atom)
        end

        until controller and action or tracks.empty?
          current = Regexp.escape(tracks.pop.to_s)
          paraction = path.gsub(/^#{current}/, '').split('/').map{|e| CGI.unescape(e)}
          paraction.delete('')
          if controller = Ramaze::Global.mapping[current] and controller.respond_to?(:render)
            if paraction == ['error']

              action = paraction.shift
              params = paraction
              action = 'index' if action == nil
            else
              action, params = resolve_action controller, paraction
            end
          end
        end

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

      def resolve_action controller, paraction
        Informer.meth_debug :resolve_action, controller, paraction

        meths =
          (controller.ancestors - [Kernel, Object]).inject([]) do |sum, klass|
            sum | (klass.is_a?(Module) ? klass.instance_methods(false) : sum)
          end

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
          if meths.include?(current) #or current = controller.ancestral_trait[:template_map][current]
            arity = controller.instance_method(current).arity
            params = (paraction - current.split('__'))

            if params.size == arity
              return current, params
            elsif arity < 0
              return current, params
            end
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
          ancestral_trait[:cache_all],
          ancestral_trait[:actions_cached].map{|k| k.to_s}.include?(action.to_s),
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
        engine = ancestral_trait[:engine] || engine_for(file)

        options = {
          :file     => file,
          :binding  => controller.send(:send, :binding),
          :action => action,
          :parameter => parameter,
        }
        engine.transform(controller, options)
      end

      def cached_render action, *parameter
        key = [action, parameter].inspect

        trait[:action_cache] ||= Global.cache.new

        if out = ancestral_trait[:action_cache][key]
          Informer.debug "Using Cached version for #{key}"
          return out
        end

        Informer.debug "Compiling Action: #{action} #{parameter.join(', ')}"
        ancestral_trait[:action_cache][key] = uncached_render(action, *parameter)
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
        action = action.to_s
        custom_template = ancestral_trait["#{action}_template".intern]
        action = custom_template.to_s if custom_template
        action_converted = action.split('__').inject {|s,v| "#{s}/#{v}"}

        first_path =
          if template_root = klass.ancestral_trait[:template_root]
            template_root
          else
            Global.template_root / Global.mapping.invert[self]
          end

        extensions = [ancestral_trait[:template_extensions].values].flatten.uniq

        paths = [ first_path, ancestral_trait[:public], ].
                  map{|pa| [ pa / action, pa / action_converted ] }.
                  flatten.map{|pa| File.expand_path(pa) }.join(',')

        glob = "{#{paths}}.{#{extensions.join(',')}}"

        possible = Dir[glob]
        possible.first
      end

      # lookup the trait[:template_extensions] for the extname of the filename
      # you pass.
      #
      # Answers with the engine that matches the extension, Template::Ezamar
      # is used if none matches.

      def engine_for file
        file = file.to_s
        extension = File.extname(file).gsub(/^\./, '')
        engines = trait[:template_extensions]
        engines.find{|k,v| v == extension or [v].flatten.include?(extension)}.first
      rescue
        Template::Ezamar
      end

      # This method is called by templating-engines to register themselves with
      # a list of extensions that will be looked up on #render of an action.

      def register_engine engine, *extensions
        trait[:template_extensions][engine] = [extensions].flatten.uniq
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
      backtrace = error.backtrace[0..20]
      title = error.message

      colors = []
      min = 200
      max = 255
      step = -((max - min) / backtrace.size).abs
      max.step(min, step) do |color|
        colors << color
      end

      backtrace.map! do |line|
        file, lineno, meth = line.scan(/(.*?):(\d+)(?::in `(.*?)')?/).first
        lines = __caller_lines__(file, lineno, Global.inform_backtrace_size)
        [ lines, lines.object_id.abs, file, lineno, meth ]
      end

      response.status = 404

      @backtrace = backtrace
      @colors = colors
      @title = CGI.escapeHTML(title)
      require 'coderay'
      @coderay = true
    rescue LoadError => ex
      @coderay = false
    end
  end
end
