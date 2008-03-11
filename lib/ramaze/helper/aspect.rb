#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
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

  module Helper::Aspect

    private

    # lazily and smartly inherit copy of aspects trait from parent, or
    # bootstrap our own 
    def aspects
      trait[:aspects] ||= (
        if hash = ancestral_trait[:aspects]
          { :before => hash[:before].dup, :after => hash[:after].dup }
        else
          { :before => {}, :after => {} }
        end
      )
    end

    # run block before given actions or, if no actions specified, all actions.
    def before(*meths, &block)
      return before_all(*meths, &block) if meths.empty?
      meths.each do |meth|
        aspects[:before][meth.to_s] = block
      end
    end
    alias pre before

    # Run block before all actions.
    def before_all(&block)
      aspects[:before][:all] = block
    end
    alias pre_all before_all

    # run block after given actions or, if no actions specified, all actions.
    def after(*meths, &block)
      return after_all(*meths, &block) if meths.empty?
      meths.each do |meth|
        aspects[:after][meth.to_s] = block
      end
    end
    alias post after

    # Run block after all actions.
    def after_all(&block)
      aspects[:after][:all] = block
    end
    alias post_all after_all

    # run block before and after given actions, or, if no actions specified.
    # all actions
    def wrap(*meths, &block)
      return wrap_all(*meths, &block) if meths.empty?
      before(*meths, &block)
      after(*meths, &block)
    end

    # run block before and after all actions.
    def wrap_all(&block)
      aspects[:before][:all] = block
      aspects[:after][:all] = block
    end
  end

  class Action

    # overwrites the default Action hook and runs the neccesary blocks in its
    # scope.
    def before_process
      return unless path and aspects = controller.ancestral_trait[:aspects]
      [ aspects[:before][name], aspects[:before][:all] ].compact.map do |block|
        instance.instance_eval(&block) if block
      end
    end

    # overwrites the default Action hook and runs the neccesary blocks in its
    # scope.
    def after_process
      return unless path and aspects = controller.ancestral_trait[:aspects]
      [ aspects[:after][name], aspects[:after][:all] ].compact.map do |block|
        instance.instance_eval(&block) if block
      end
    end
  end
end
