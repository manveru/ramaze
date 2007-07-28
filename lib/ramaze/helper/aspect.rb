#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # A helper that provides the means to wrap actions of the controller with
  # other methods.
  #
  # For examples please look at the spec/ramaze/helper/aspect.rb
  #
  # This is not a default helper due to the possible performance-issues.
  # However, it should be only an overhead of about 6-8 calls, so if you
  # want this feature it shouldn't have too large impact ;)
  #
  # Like every other helper, you can use it in your controller with:
  #
  #   helper :aspect

  module AspectHelper

    # Define traits on class this module is included into.

    def self.included(klass)
      klass.trait[:aspects] ||= { :before => {}, :after => {} }
    end

    private

    # run block before given actions.
    def before(*meths, &block)
      aspects = trait[:aspects][:before]
      meths.each do |meth|
        aspects[meth.to_s] = block
      end
    end
    alias pre before

    # Run block before all actions that were defined up to this point.
    def before_all(&block)
      meths = instance_methods(false)
      before(*meths, &block)
    end
    alias pre_all before_all

    # run block after given actions.
    def after(*meths, &block)
      aspects = trait[:aspects][:after]
      meths.each do |meth|
        aspects[meth.to_s] = block
      end
    end
    alias post after

    # Run block after all actions that were defined up to this point.
    def after_all(&block)
      meths = instance_methods(false)
      after(*meths, &block)
    end
    alias post_all after_all

    # run block before and after given actions.
    def wrap(*meths, &block)
      before(*meths, &block)
      after(*meths, &block)
    end

    # run block before and after all actions.
    def wrap_all(&block)
      meths = instance_methods(false)
      wrap(*meths, &block)
    end
  end

  class Action

    # overwrites the default Action hook and runs the neccesary blocks in its
    # scope.
    def before_process
      return unless aspects = controller.ancestral_trait[:aspects]
      block = aspects[:before][method]
      instance.instance_eval(&block) if block
    end

    # overwrites the default Action hook and runs the neccesary blocks in its
    # scope.
    def after_process
      return unless aspects = controller.ancestral_trait[:aspects]
      block = aspects[:after][method]
      instance.instance_eval(&block) if block
    end
  end
end
