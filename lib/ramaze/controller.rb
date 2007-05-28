#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'ramaze/helper'
require 'ramaze/template'
require 'ramaze/action'

require 'ramaze/controller/resolve'
require 'ramaze/controller/render'
require 'ramaze/controller/error'

module Ramaze

  # The Controller is responsible for combining and rendering actions.

  class Controller
    include Ramaze::Helper
    extend Ramaze::Helper

    helper :redirect, :link, :file, :flash, :cgi

    trait[:template_extensions] ||= {}

    # Whether or not to map this controller on startup automatically

    trait[:automap] ||= true

    # Place to map the Controller to, this is something like '/' or '/foo'

    trait[:map] ||= nil

    trait :exclude_action_modules => [Kernel, Object, PP::ObjectMixin]

    trait :pattern_cache => Hash.new{|h,k| h[k] = Controller.pattern_for(k) }

    class << self
      include Ramaze::Helper
      extend Ramaze::Helper

      def inherited controller
        controller.trait :actions_cached => Set.new
        Global.controllers << controller
      end

      def startup options = {}
        Inform.debug("found Controllers: #{Global.controllers.inspect}")

        Cache.add :actions, :patterns

        Global.controllers.each do |controller|
          if map = controller.mapping
            Inform.debug("mapping #{map} => #{controller}")
            Global.mapping[map] ||= controller
          end
        end

        Inform.debug("mapped Controllers: #{Global.mapping.inspect}")
      end

      def check_path(path, message)
        Inform.warn(message) unless File.directory?(path)
      end

      def mapping
        global_mapping = Global.mapping.invert[self]
        return global_mapping if global_mapping
        if ancestral_trait[:automap]
          name = self.to_s.gsub('Controller', '').split('::').last
          %w[Main Base Index].include?(name) ? '/' : "/#{name.snake_case}"
        end
      end

      def map(*syms)
        syms.each do |sym|
          Global.mapping[sym.to_s] = self
        end
      end

      def template_root path = nil
        if path
          message = "#{self}.template_root is #{path} which does not exist"
          check_path(path, message)
          @template_root = path
        else
          @template_root
        end
      end

      def template(this, from, that = nil)
        from, that = self, from unless that
        trait "#{this}_template" => [from, that.to_s]
      end

      def current
        Thread.current[:controller]
      end

      def handle path
        controller, action = *resolve(path)
        controller.render(action)
      end
    end

    private

    def render *args
      self.class.handle(*args)
    end
  end
end
