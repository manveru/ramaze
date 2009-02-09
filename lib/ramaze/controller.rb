#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    include Innate::Node

    # we are no mapped node
    Innate::Node::LIST.delete(self)

    LIST = Set.new

    trait :automap => true

    def self.inherited(into)
      Innate::Node.included(into)
      into.engine(:Nagoro)
      LIST << into
    end

    def self.engine(*symbols)
      symbols.each do |symbol|
        regex = /#{symbol}/i
        Innate::View::ENGINE.each do |ext, constant|
          provide(:html => ext) if constant =~ regex
        end
      end
    end

    def self.mapping
      mapped = Innate.to(self)
      return mapped if mapped
      return unless ancestral_trait[:automap]
      return if self.to_s =~ /#<Class:/ # cannot determine name of anonymous class

      name = self.to_s.gsub('Controller', '').gsub('::', '/').clone
      return if name.empty? # won't map a class named Controller
      name == 'Main' ? '/' : "/#{name.snake_case}"
    end

    def self.template(*args)
      Ramaze.deprecated('Controller::template', 'Controller::alias_view')
      alias_view(*args)
    end
  end
end
