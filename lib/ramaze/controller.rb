#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    include Innate::Node

    # we are no mapped node
    Innate::Node::LIST.delete(self)

    LIST = Set.new

    def self.inherited(into)
      Innate::Node.included(into)
      LIST << into
    end

    def self.setup
      LIST.each{|controller| controller.mapping }
    end

    # if trait[:automap] is set and controller is not in Global.mapping yet
    # this will build a new default mapping-point, MainController is put
    # at '/' by default. For other Class names, String#snake_case is called,
    # e.g. FooBarController is mapped at '/foo_bar'.

    def self.mapping
      existing_mapping = Innate.to(self)
      return existing_mapping if existing_mapping

      automap if ancestral_trait[:automap] && self.to_s !~ /#<Class:/
    end

    def automap
      name = self.to_s.gsub('Controller', '').gsub('::', '/').clone
      return if name.empty?
      name == 'Main' ? '/' : "/#{name.snake_case}"
    end

    def self.engine(name)
      provide(:html => name)
    end
  end
end
