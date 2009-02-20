#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'liquid'

module Ramaze
  module View
    module Liquid
      def self.render(action, string = nil)
        instance_variables = {}
        instance = action.instance

        instance.instance_variables.each do |iv|
          instance_variables[iv.to_s[1..-1]] = instance.instance_variable_get(iv)
        end

        template = ::Liquid::Template.parse(string)
        template.render(instance_variables)

        # data = action.variables[:data] || {}
        # template.render(data, options)
      end

      class Tag < ::Liquid::Tag
        def initialize(tag_name, arg, tokens)
          super
          @arg = arg.strip
        end
      end

      # Liquid has intentionally? no support for binding, in order to use
      # helpers you have to register them as tags.
      #
      # Creating a tag needs boilerplate, so we reduce that for your
      # convenience.
      #
      # This is not the most performant way, it seems like Liquid uses
      # initialize to compile templates and gives you the chance to process the
      # arguments to the tag only once, but if you want that please contribute.
      #
      # Further below are a couple of tags that map to the most common helpers,
      # this also needs contribution as I simply don't have the time to write
      # all of that and invent a consistent syntax.
      def self.register_tag(name, helper, &block)
        klass = Class.new(Tag)
        klass.send(:include, helper)
        klass.send(:define_method, :render, &block)

        ::Liquid::Template.register_tag(name, klass)
      end

      # {% route index %}
      register_tag('route', Ramaze::Helper::Link) do |context|
        Ramaze::Current.action.node.route(@arg)
      end

      # {% anchor "The index" index %}
      register_tag('anchor', Ramaze::Helper::Link) do |context|
        @arg =~ /^(['"])(.*?)\1\s+(.*)/
        Ramaze::Current.action.node.anchor($2, $3)
      end
    end
  end
end
