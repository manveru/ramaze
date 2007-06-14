#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    class << self
      # #ramaze - 9.5.2007
      #
      # manveru: if no possible controller is found, it's a NoController error
      # manveru: that would be a 404 then
      # Kashia: aye
      # manveru: if some controller are found but no actions on them, it's NoAction Error for the first controller found, again, 404
      # manveru: everything further down is considered 500

      def resolve(path)
        if found = Cache.resolved[path]
          return found
        end

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

            valid_action = (action.method or (params.empty? && action.template))

            return Cache.resolved[path] = action if valid_action
          end
        end

        raise_no_action(first_controller, path) if first_controller
        raise_no_controller(path)
      end

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

      def resolve_template(action)
        action = action.to_s
        action_converted = action.split('__').inject{|s,v| s/v}
        actions = [action, action_converted].compact

        paths = template_paths.map{|pa| actions.map{|a| pa/a } }.flatten.uniq
        glob = "{#{paths.join(',')}}.{#{extension_order.join(',')}}"

        Dir[glob].first
      end

      def template_paths
        @template_root ||= Global.template_root / Global.mapping.invert[self]
        [ @template_root, Global.public_root, Global.public_proto ].compact
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
        raise Ramaze::Error::NoAction, "No Action found for `#{path}' on #{controller}"
      end
    end
  end
end
