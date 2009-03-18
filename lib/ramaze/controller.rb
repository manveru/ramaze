#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    include Innate::Traited
    include Innate::Node

    # we are no mapped node
    Innate::Node::NODE_LIST.delete(self)

    CONTROLLER_LIST = Set.new

    trait :automap => true, :app => :pristine

    def self.inherited(into)
      Innate::Node.included(into)
      CONTROLLER_LIST << into

      return if into.ancestral_trait[:provide_set]
      into.provide(:html, :Nagoro)
      into.trait(:provide_set => false)
    end

    def self.engine(name)
      provide(:html, name.to_sym)
    end

    def self.mapping
      if mapped = App[ancestral_trait[:app]].to(self)
        mapped
      elsif ancestral_trait[:automap]
        generate_mapping(self.name)
      end
    end

    IRREGULAR_MAPPING = {
      'Controller' => nil,
      'MainController' => '/'
    }

    def self.generate_mapping(klass)
      chunks = klass.split(/::/)
      return if chunks.empty?

      last = chunks.last
      return IRREGULAR_MAPPING[last] if IRREGULAR_MAPPING.key?(last)

      last.sub!(/Controller$/, '')
      ['', *chunks.map{|chunk| chunk.snake_case }].join('/')
    end

    def self.template(*args)
      Ramaze.deprecated('Controller::template', 'Controller::alias_view')
      alias_view(*args)
    end

    def self.map(location, app_name = :pristine)
      trait :app => app_name
      App.find_or_create(app_name).map(location, self)
    end

    def self.app
      App[ancestral_trait[:app]]
    end

    def self.options
      app.options
    end
  end
end
