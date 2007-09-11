#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    FILTER = [ :cached, :default ]

    class << self
      # #ramaze - 9.5.2007
      #
      # manveru: if no possible controller is found, it's a NoController error
      # manveru: that would be a 404 then
      # Kashia: aye
      # manveru: if some controller are found but no actions on them, it's NoAction Error for the first controller found, again, 404
      # manveru: everything further down is considered 500

      def resolve(path, *exclude_filter)
        (FILTER - exclude_filter.flatten).each do |filter|
          answer = filter.respond_to?(:call) ? filter.call(path) : send(filter, path)
          return answer if answer
        end
        raise_no_filter(path)
      end

      def default(path)
        mapping     = Global.mapping
        controllers = Global.controllers

        raise_no_controller(path) if controllers.empty? or mapping.empty?

        patterns = Cache.patterns[path] ||= pattern_for(path)
        first_controller = nil

        patterns.each do |controller, method, params|
          if controller = mapping[controller]
            first_controller ||= controller

            action = controller.resolve_action(method, *params)
            template = action.template

            valid_action = (action.method or (params.empty? && template))

            if valid_action
              Cache.resolved[path] = action
              return action.dup
            end
          end
        end

        raise_no_action(first_controller, path) if first_controller
        raise_no_controller(path)
      end

      def cached(path)
        if found = Cache.resolved[path]
          if found.respond_to?(:relaxed_hash)
            return found.dup
          else
            Inform.warn("Found faulty `#{path}' in Cache.resolved, deleting it for sanity.")
            Cache.resolved.delete path
          end
        end
      end

      # Try to produce an Action from the given path and paremters with the
      # appropiate template if one exists.
      def resolve_action(path, *parameter)
        path, parameter = path.to_s, parameter.map(&:to_s)
        if alternate_template = trait["#{path}_template"]
          t_controller, t_path = *alternate_template
          template = t_controller.resolve_template(t_path)
        end

        method, params = resolve_method(path, *parameter)

        if method or parameter.empty?
          template ||= resolve_template(path)
        end

        Action.create :path       => path,
                      :method     => method,
                      :params     => params,
                      :template   => template,
                      :controller => self
      end

      # Search the #template_paths for a fitting template for path.
      # Only the first found possibility for the generated glob is returned.
      def resolve_template(path)
        path = path.to_s
        path_converted = path.split('__').inject{|s,v| s/v}
        possible_paths = [path, path_converted].compact

        paths = template_paths.map{|pa| possible_paths.map{|a| pa/a } }.flatten.uniq
        glob = "{#{paths.join(',')}}.{#{extension_order.join(',')}}"

        Dir[glob].first
      end

      # Composes an array with the template-paths to look up in the right order.
      # Usually this is composed of Global.template_root and the mapping of the
      # controller and a second element for Global.public_root, which makes
      # it possible to convert CSS on the fly and things like that.

      def template_paths
        @template_root ||= Global.template_root / Global.mapping.invert[self]
        [ @template_root, Global.public_root ].compact
      end

      # Based on methodname and arity, tries to find the right method on current controller.
      def resolve_method(name, *params)
        if method = action_methods.delete(name)
          arity = instance_method(method).arity
          if params.size == arity or arity < 0
            return method, params
          end
        end
        return nil, []
      end

      # methodnames that may be used for current controller.
      def action_methods
        exclude = Controller.trait[:exclude_action_modules]

        ancs = (ancestors - exclude).select{|a| a.is_a?(Module)}
        meths = ancs.map{|a| a.instance_methods(false).map(&:to_s)}.flatten.uniq
        # fix for facets/more/paramix
        meths - ancs.map(&:to_s)
      end

      # Generate all possible permutations for given path.
      def pattern_for(path)
        atoms = path.split('/').grep(/\S/)
        atoms.unshift('')
        patterns, joiner = [], '/'

        atoms.size.times do |enum|
          enum += 1
          pattern = atoms.dup

          controller = pattern[0, enum].join(joiner)
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

        patterns.reverse!
      end

      # Uses custom defined engines and all available engines and throws it
      # against the extensions for the template to find the most likely
      # templating-engine to use ordered by priority and likelyhood.
      def extension_order
        t_extensions = Template::ENGINES
        engine = trait[:engine]
        c_extensions = t_extensions.select{|k,v| k == engine}.map{|k,v| v}.flatten
        all_extensions = t_extensions.map{|k,v| v}.flatten
        (c_extensions + all_extensions).uniq
      end

      # Raises Ramaze::Error::NoController

      def raise_no_controller(path)
        raise Ramaze::Error::NoController, "No Controller found for `#{path}'"
      end

      # Raises Ramaze::Error::NoAction

      def raise_no_action(controller, path)
        Thread.current[:controller] = controller
        raise Ramaze::Error::NoAction, "No Action found for `#{path}' on #{controller}"
      end
    end
  end
end
