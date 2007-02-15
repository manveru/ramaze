#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/helper'

module Ramaze
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

      # The universal #render method that has to be provided by every
      # prospective Controller, pass it your action and parameters.
      #
      # This is called upon by the Dispatcher, but you can use it in your
      # Controller/View to get the contents of another action.
      #
      # It will set the instance-variable @action in the instance of itself
      # to the value of the current action.

      def render action, *parameter
        file = find_template(action)

        controller = self.new
        controller.instance_variable_set('@action', action)

        engine = ancestral_trait[:engine] || engine_for(file)
        options = {
          :file     => file,
          :binding  => controller.send(:send, :binding),
          :action => action,
          :parameter => parameter,
        }
        engine.transform(controller, options)
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
        action = custom_template if custom_template
        action_converted = action.split('__').inject{|s,v| s/v}

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
        extension = File.extname(file)
        trait[:template_extensions].invert[extension]
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
      min = 160
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

      @backtrace = backtrace
      @colors = colors
      @title = title
      require 'coderay'
      @coderay = true
    rescue LoadError => ex
      @coderay = false
    end
  end
end
