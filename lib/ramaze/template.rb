#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/helper'

module Ramaze::Template
  %w[ Amrita2 Erubis Haml Liquid Markaby Ramaze ].each do |const|
    autoload(const, "ramaze/template/#{const.downcase}")
  end

  class Template
    extend ::Ramaze::Helper

    trait :public => ( ::Ramaze::BASEDIR / 'proto' / 'public' )

    helper :link, :redirect

    # This finds the template for the given action on the current controller
    # there are some basic ways how you can provide an alternative path:
    #
    # Global.template_root = 'default/path'
    #
    # class FooController < Template::Ramaze
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

    def self.find_template action
      action = action.to_s
      custom_template = ancestral_trait["#{action}_template".intern]
      action = custom_template if custom_template

      first_path =
        if template_root = ancestral_trait[:template_root]
          template_root
        else
          Global.template_root / Global.mapping.invert[self]
        end

      extensions = ancestral_trait[:template_extensions]

      paths = [ first_path, ancestral_trait[:public], ]
      paths = paths.map{|pa| File.expand_path(pa / action)}.join(',')

      possible = Dir["{#{paths}}.{#{extensions.join(',')}}"]
      possible.first
    end

    private

    # just call self.class.find_template(action)

    def find_template action
      self.class.find_template(action)
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
