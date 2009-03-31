#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    include Innate::Traited
    include Innate::Node

    # we are no mapped node
    Innate::Node::NODE_LIST.delete(self)

    # call our setup method one startup
    Ramaze.options.setup << self

    CONTROLLER_LIST = Set.new

    trait :app => :pristine
    trait :skip_controller_map => false

    def self.inherited(into)
      Innate::Node.included(into)
      CONTROLLER_LIST << into
      into.trait :skip_node_map => true
    end

    def self.setup
      require 'ramaze/controller/default' if CONTROLLER_LIST.empty?

      CONTROLLER_LIST.each do |controller|
        unless controller.ancestral_trait[:provide_set]
          controller.engine(:Etanni)
          controller.trait(:provide_set => false)
        end
        next if controller.trait[:skip_controller_map]
        controller.map(generate_mapping(controller.name))
      end
    end

    def self.engine(name)
      provide(:html, name.to_sym)
    end

    def self.mapping
      Ramaze.to(self)
    end

    IRREGULAR_MAPPING = {
      'Controller' => nil,
      'MainController' => '/'
    }

    def self.generate_mapping(klass_name = self.name)
      chunks = klass_name.split(/::/)
      return if chunks.empty?

      last = chunks.last
      return IRREGULAR_MAPPING[last] if IRREGULAR_MAPPING.key?(last)

      last.sub!(/Controller$/, '')
      '/' << chunks.map{|chunk| chunk.snake_case }.join('/')
    end

    def self.map(location, app_name = nil)
      if app_name
        trait :app => app_name
      else
        app_name = ancestral_trait[:app]
      end

      trait :skip_controller_map => true

      App.find_or_create(app_name).map(location, self)
    end

    def self.app
      App[ancestral_trait[:app]]
    end

    def self.options
      return unless app = self.app
      app.options
    end

    def self.template(*args)
      Ramaze.deprecated('Controller::template', 'Controller::alias_view')
      alias_view(*args)
    end

    def self.view_root(*locations)
      Ramaze.deprecated('Controller::view_root', 'Controller::map_views')
      map_views(*locations)
    end
  end
end
