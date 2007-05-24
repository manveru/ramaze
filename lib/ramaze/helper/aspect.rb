#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # A helper that provides the means to wrap actions of the controller with
  # other methods.
  #
  # For examples please look at the test/tc_aspect.rb
  #
  # This is not a default helper due to the possible performance-issues.
  # However, it should be only an overhead of about 6-8 calls, so if you
  # want this feature it shouldn't have too large impact ;)

  module AspectHelper
    def self.included(klass)
      klass.trait[:aspects] ||= { :before => {}, :after => {} }
    end

    private

    def before(*meths, &block)
      aspects = trait[:aspects][:before]
      meths.each do |meth|
        aspects[meth.to_s] = block
      end
    end
    alias pre before

    def before_all(&block)
      meths = instance_methods(false)
      before(*meths, &block)
    end
    alias pre_all before_all

    def after(*meths, &block)
      aspects = trait[:aspects][:after]
      meths.each do |meth|
        aspects[meth.to_s] = block
      end
    end
    alias post after

    def after_all(&block)
      meths = instance_methods(false)
      after(*meths, &block)
    end
    alias post_all after_all

    def wrap(*meths, &block)
      before(*meths, &block)
      after(*meths, &block)
    end

    def wrap_all(&block)
      meths = instance_methods(false)
      wrap(*meths, &block)
    end

    def before_process(action)
      block = ancestral_trait[:aspects][:before][action.method]
      before = action.controller.instance_eval(&block) if block
      before
    end

    def after_process(action)
      block = ancestral_trait[:aspects][:after][action.method]
      after = action.controller.instance_eval(&block) if block
      after
    end

    module_function :before_process, :after_process
  end
end
