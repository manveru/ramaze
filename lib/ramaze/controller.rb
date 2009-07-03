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
      into.helper(:layout)
      CONTROLLER_LIST << into
      into.trait :skip_node_map => true
    end

    def self.setup
      case CONTROLLER_LIST.size
      when 0
        require 'ramaze/controller/default'
      when 1
        controller = CONTROLLER_LIST.to_a.first

        begin
          controller.mapping
        rescue
          controller.map '/'
        end

        controller.setup_procedure
      else
        CONTROLLER_LIST.each do |controller|
          controller.setup_procedure
        end
      end
    end

    def self.setup_procedure
      unless ancestral_trait[:provide_set]
        engine(:Etanni)
        trait(:provide_set => false)
      end

      map(generate_mapping(name)) unless trait[:skip_controller_map]
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
      chunks = klass_name.to_s.split(/::/)
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
  end
end
