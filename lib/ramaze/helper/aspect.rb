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

    # define the trait[:aspects] for the class that includes us
    # also prepare hijacking of the :render method

    def self.included(klass)
      # if we haven't been included yet...
      unless defined?(Traits[klass][:aspects]) and Traits[klass][:aspects]
        klass.trait :aspects => {:pre => {}, :post => {}, :wrap => {}}
        unless defined?(klass.old_render)
          klass.class_eval do
            class << self
              include AspectHelperMixin
              alias_method :old_render, :render
              alias_method :render, :new_render

              public :render
            end
          end
        end
      end
    end
  end

  # This is the actual Module to be included into the Controller you call
  #   helper :aspect
  # from.
  #
  # The reason for that is to avoid recursion of inclusion in AspectHelper
  # which does the aliasing and predefinition of the traits for the aspects.

  module AspectHelperMixin
    private

    # define pre-aspect which calls render(:your_pre_aspect)
    # and appends it on your default action
    # please note, that if you give can define
    #   pre :all, :all_, :except => [:action1, :action2]
    #   pre :all, :all_, :except => :action
    # however, due to the nature of this helper, only action that have been
    # defined so far are wrapped by the :all.
    # methods that are in the :except (which is not mandatory) are ignored.
    #
    # the notion :all_ is a nice reminder that it is a pre-wrapper, you don't
    # have to use the underscore, it's just my way to do it.
    #
    # Also, be careful, since :all will wrap other wraps that have been defined
    # so far as well.
    # Usually i don't think it's a good thing that order defines
    # behaviour, but in this case it gives you quite powerful control
    # over the whole process. Just watch out:
    #   With great power comes great responsibility
    #
    # Example:
    #   class FooController < Controller
    #
    #     def index
    #       'foo'
    #     end
    #     pre :index, :_index
    #
    #     def other
    #       'foo'
    #     end
    #     pre :all, :all_, :except => :index
    #
    #     def _index
    #       'I will be put before your action'
    #     end
    #
    #     def _all
    #       '<pre>'
    #     end
    #   end

    def pre(*opts)
      enwrap(:pre, *opts)
    end
    alias before pre

    # define post-aspect which calls render(:your_post_aspect)
    # and appends it on your default action
    # please note, that if you give can define
    #   post :all, :all_, :except => [:action1, :action2]
    #   post :all, :all_, :except => :action
    # however, due to the nature of this helper, only action that have been
    # defined so far are wrapped by the :all.
    # methods that are in the :except (which is not mandatory) are ignored.
    #
    # the notion :all_ is a nice reminder that it is a post-wrapper, you don't
    # have to use the underscore, it's just my way to do it.
    #
    # Also, be careful, since :all will wrap other wraps that have been defined
    # so far as well.
    # Usually i don't think it's a good thing that order defines
    # behaviour, but in this case it gives you quite powerful control
    # over the whole process. Just watch out:
    #   With great power comes great responsibility
    #
    # Example:
    #   class FooController < Controller
    #
    #     def index
    #       'foo'
    #     end
    #     post :index, :index_
    #
    #     def other
    #       'foo'
    #     end
    #     pre :all, :all_, :except => :index
    #
    #     def index_
    #       'I will be put after your action'
    #     end
    #
    #     def all_
    #       '</pre>'
    #     end
    #   end

    def post(*opts)
      enwrap(:post, *opts)
    end
    alias after post

    # a shortcut that combines pre and post
    # same syntax as pre/post, just a linesaver

    def wrap(*opts)
      pre(*opts)
      post(*opts)
    end

    # you shouldn't have to call this method directly
    # however, if you really, really want to:
    #
    # enwrap(:post, :index, :my_post_method, :except => :bar

    def enwrap(kind, key, meths, hash = {})
      wrapping =
      if key == :all
        instance_methods(false).map{|im| im.to_sym}
      else
        if ([] + key rescue nil)
          key.map{|k| k.to_sym}
        else
          [key.to_sym]
        end
      end

      if hash[:except]
        wrapping -= [hash[:except]].flatten.map{|m| m.to_sym}
      end

      wrapping.each do |meth|
        ancestral_trait[:aspects][kind][meth] = meths
      end
    end

    # find the post and pre actions for the current class

    def resolve_aspect(action)
      action = action.to_sym
      aspects = ancestral_trait[:aspects]
      {
        :pre  => aspects[:pre][action],
        :post => aspects[:post][action]
      }
    end

    # this will be exchanged for the :render method which is aliased
    # to old_render
    # it just searches for post and pre wrappers, calls them
    # before/after your action and joins the results

    def new_render(action)
      arity_for = lambda{|meth| method(meth).arity rescue -1 }
      post, pre = resolve_aspect(action.method).values_at(:post, :pre)

      if pre
        arity = arity_for[pre].abs
        pre_action = Action.new(pre, action.params, action.template)
        pre_content = old_render(pre_action)
      end

      unless (pre_content.delete(:skip_next_aspects) rescue false)
        content = old_render(action)

        if post
          arity = arity_for[post].abs
          post_action = Action.new(post, action.params, action.template)
          post_content = old_render(post_action)
        end
      end

      [pre_content, content, post_content].join
    end
  end
end
