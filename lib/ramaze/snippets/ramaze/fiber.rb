module Ramaze
  class Fiber < ::Fiber
    attr_accessor :state

    def initialize(*args)
      super
      @state = {}
    end

    attr_accessor :state

    def [](key)
      @state[key]
    end

    def []=(key, value)
      @state[key] = value
    end

    def key?(key)
      @state.key?(key)
    end
  end if defined?(::Fiber)
end
