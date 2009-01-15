#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze
  class Controller
    include Innate::Node

    # Assign default mapping

    def self.inherited(into)
      into.map_smart
      into.provide(:html => :erb)
    end

    def self.map_smart
      name = self.to_s.gsub('Controller', '').gsub('::', '/')
      return if name.empty?
      mapping = name == 'Main' ? '/' : "/#{name.snake_case}"
      map(mapping)
    end

    def self.engine(name)
      provide(:html => name)
    end
  end
end
